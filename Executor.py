import os
import subprocess
import shutil
import docker


class Executor:
    def __init__(self, docker_path, shell_path, log_path, project_path, docker_log_path):
        self.docker_path = docker_path
        self.shell_path = shell_path
        self.project_path = project_path
        self.log_path = log_path
        self.docker_log_path = docker_log_path

    
    # def build_docker_image(self, image_name):
    #     if not os.path.isdir(self.project_path):
    #         raise ValueError(f"Invalid project path: {self.project_path}")

    #     # os.makedirs(os.path.dirname(self.docker_log_path), exist_ok=True)

    #     client = docker.from_env()

    #     log_lines = []

    #     try:
    #         # Stream the build logs and write to console and file
    #         print(f"Building Docker image: {image_name}")
    #         output = client.api.build(path=self.project_path, tag=image_name, decode=True)

    #         with open(self.docker_log_path, "w") as log_file:
    #             for chunk in output:
    #                 if "stream" in chunk:
    #                     line = chunk["stream"].strip()
    #                     if line:
    #                         print(line)  # Console output
    #                         log_file.write(line + "\n")
    #                         log_lines.append(line)

    #         return {
    #             "completed": True,
    #             "success": True,
    #             "stdout": "\n".join(log_lines),
    #             "stderr": "",
    #             "log": "\n".join(log_lines)
    #         }

    #     except docker.errors.BuildError as e:
    #         error_msg = f"Build failed: {e}"
    #         print(error_msg)

    #         with open(self.docker_log_path, "a") as log_file:
    #             log_file.write(error_msg + "\n")
    #             log_lines.append(error_msg)

    #         return {
    #             "completed": False,
    #             "success": False,
    #             "stdout": "",
    #             "stderr": str(e),
    #             "error_log": "\n".join(log_lines)
    #         }
    
    
    def build_docker_image(self, image_name):
        if not os.path.isdir(self.project_path):
            raise ValueError(f"Invalid project path: {self.project_path}")

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
            container = client.containers.run(
                image=image_tag,
                detach=True,
                stdout=True,
                stderr=True,
                remove=False,  # Don't auto-remove so we can inspect on failure
                sysctls={"net.ipv6.conf.all.disable_ipv6": "0"}
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