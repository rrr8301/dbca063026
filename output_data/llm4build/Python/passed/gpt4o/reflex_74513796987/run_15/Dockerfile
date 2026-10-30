# Use a stable Python base image
FROM python:3.11-slim

# Set the working directory
WORKDIR /app

# Copy the project files into the container
COPY . .

# Install Poetry
RUN pip install poetry

# Ensure the pyproject.toml has the required version field
RUN if ! grep -q '\[tool.poetry.version\]' pyproject.toml && ! grep -q '\[project.version\]' pyproject.toml; then \
      echo "[tool.poetry]\nversion = \"0.1.0\"" >> pyproject.toml; \
    fi

# Install project dependencies
RUN poetry install

# Expose the port for Redis (if needed)
EXPOSE 6379

# Set the entrypoint to the run.sh script
ENTRYPOINT ["./run.sh"]