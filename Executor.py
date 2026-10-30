import os
import subprocess
import shutil
import docker


class Executor:
    def __init__(self, docker_path, shell_path, log_path, project_path, docker_log_path, cpus=None, shm_size=None, cpu_offset=0,
                 env=None):
        self.docker_path = docker_path
        self.env = env or {}           # extra environment variables of the test container
        self.cpus = cpus
        self.cpu_offset = cpu_offset
        self.shm_size = shm_size
        self.shell_path = shell_path
        self.project_path = project_path
        self.log_path = log_path
        self.docker_log_path = docker_log_path

    
    def remove_existing_image(self, image_name):
        """Remove an earlier image with this name (an earlier attempt or run) and any container left
        from it. Rebuilding under the same tag would otherwise keep the old image as an untagged
        (dangling) one: a few GB per failed attempt."""
        exists = subprocess.run(["docker", "image", "inspect", image_name], capture_output=True)
        if exists.returncode != 0:
            return
        containers = subprocess.run(["docker", "ps", "-aq", "--filter", f"ancestor={image_name}"],
                                    capture_output=True, text=True).stdout.split()
        if containers:
            subprocess.run(["docker", "rm", "-f", *containers], capture_output=True)
        subprocess.run(["docker", "rmi", "-f", image_name], capture_output=True)

    def build_docker_image(self, image_name):
        if not os.path.isdir(self.project_path):
            raise ValueError(f"Invalid project path: {self.project_path}")

        self.remove_existing_image(image_name)
        # BuildKit reads <Dockerfile>.dockerignore before the repo's .dockerignore, which is written
        # for the project's production images and may drop tests (e.g. **/__tests__, **/*.test.*)
        with open(os.path.join(self.project_path, "Dockerfile.dockerignore"), "w") as f:
            f.write("# LLM4Build: send the whole repository, as the CI checkout has it\n")
        try:
            cmd = f"docker build -t {image_name} ."
            result = subprocess.run(
                cmd,
                cwd=self.project_path,
                capture_output=True,
                shell=True,
                text=True,
                check=True
            )
            ll = result.stdout + result.stderr
            ll_list = ll.split("\n")
            lll = ll_list[-20:]
            log = ('\n').join(lll)
            return {
                "completed": True,
                "success": True,
                "stdout": result.stdout,
                "stderr": result.stderr,
                "log": log
            }
        except subprocess.CalledProcessError as e:
            # with open(self.docker_log_path, "r") as file:
            #     lines = file.readlines()
            # ll = lines[-20:]
            # ll = result.stderr
            return {
                "completed": False,
                "success": False,
                "stdout": e.stdout,
                "stderr": e.stderr,
                "error_log": e.stdout + "\n" + e.stderr,
            }
        

    def execute_shell_script(self, image_tag):
        os.makedirs(os.path.dirname(self.log_path), exist_ok=True)
        client = docker.from_env()
        log_lines = []

        try:
            print(f"Running container from image: {image_tag}")
            # cpus=N: the container sees N CPUs, as the job's GitHub runner did (runner_resources.py),
            # so CPU-dependent test parallelism (pytest -n auto, --parallel-threads=auto, make -j$(nproc))
            # runs as in the original job. None: every CPU of the host. cpu_offset: the first CPU, so
            # that parallel runs get CPUs of their own.
            limits = {"cpuset_cpus": f"{self.cpu_offset}-{self.cpu_offset + self.cpus - 1}"} if self.cpus else {}
            # shm_size: Docker gives /dev/shm 64MB; a GitHub runner VM has far more, and browsers
            # (Chrome under Selenium/Puppeteer/Karma) crash at startup without it. None: Docker's default.
            if self.shm_size:
                limits["shm_size"] = self.shm_size
            container = client.containers.run(
                image=image_tag,
                detach=True,
                stdout=True,
                stderr=True,
                remove=False,  # Don't auto-remove so we can inspect on failure
                sysctls={"net.ipv6.conf.all.disable_ipv6": "0"},
                environment=self.env,
                **limits
            )

            logs = container.logs(stream=True, stdout=True, stderr=True)
            with open(self.log_path, "w") as f:
                for line in logs:
                    decoded = line.decode(errors="replace").rstrip()
                    print(decoded)
                    f.write(decoded + "\n")
                    log_lines.append(decoded)

            # Ensure container is stopped and removed
            exit_status = container.wait()
            container.remove()

            success = (exit_status.get("StatusCode", 1) == 0)

            return {
                "completed": True,
                "success": success,
                "log": "\n".join(log_lines),
                "exit_code": exit_status.get("StatusCode")
            }

        except docker.errors.ContainerError as e:
            # Still return logs if captured
            log_text = "\n".join(log_lines)
            with open(self.log_path, "w") as f:
                f.write(log_text + "\n")
            print(log_text)
            return {
                "completed": True,
                "success": False,
                "log": log_text,
                "stdout": e.stdout.decode() if e.stdout else "",
                "stderr": e.stderr.decode() if e.stderr else "",
                "error": str(e)
            }

        except Exception as e:
            log_text = "\n".join(log_lines)
            with open(self.log_path, "w") as f:
                f.write(log_text + "\n")
            print(log_text)
            print(str(e))
            return {
                "completed": False,
                "success": False,
                "log": log_text,
                "error": str(e)
            }


        
    def move_scripts_to_project_path(self, file_path, dir_path):
        if not os.path.isfile(file_path):
            raise FileNotFoundError(f"The source file '{file_path}' does not exist or is not a file.")
        
        if not os.path.exists(dir_path):
            os.makedirs(dir_path, exist_ok=True)

        shutil.copy2(file_path, dir_path)
        print(f"File '{file_path}' successfully copied to directory '{dir_path}'.")
        
        
        
    def execute(self, image_name):
        self.move_scripts_to_project_path(self.docker_path, self.project_path)
        self.move_scripts_to_project_path(self.shell_path, self.project_path)

        docker_output = self.build_docker_image(image_name)
        print('docker build output ', docker_output)

        if docker_output['success'] == False:
            # Save docker build error to log.txt so the pipeline can read it
            error_log = docker_output.get('error_log', docker_output.get('stderr', ''))
            with open(self.log_path, 'w') as f:
                f.write("Error from docker build\n" + error_log)
            return {
                "success": False,
                "error_log": error_log,
                "log_lines": []
            }

        shell_output = self.execute_shell_script(image_name)
        log_lines = shell_output.get('log', '').splitlines()
        return {
            "success": shell_output['success'],
            "log_lines": log_lines,
            "exit_code": shell_output.get('exit_code'),
            "error": shell_output.get('error', '')
        }