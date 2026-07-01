#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install project dependencies
echo "Installing project dependencies..."
python -m pip install --upgrade pip setuptools wheel
if [ -f requirements-dev.txt ]; then
    python -m pip install -r requirements-dev.txt
fi

# Check if this is an ONNX Runtime repository (has build.py)
if [ -f "build.py" ]; then
    echo "Detected ONNX Runtime repository with build.py"
    echo "Running build.py to generate build artifacts..."
    python build.py --config Release --build_wheel 2>&1 || {
        echo "Build failed"
        exit 1
    }
    
    echo "Build completed successfully!"
    
    # Run pytest if available
    if command -v pytest &> /dev/null; then
        echo "Running tests with pytest..."
        pytest -v --tb=short 2>&1 || {
            echo "Some tests failed or no tests were found"
            exit 1
        }
    else
        echo "pytest not found, skipping tests"
    fi
# Check if this is a standard Python project with setup.py or pyproject.toml
elif [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
    echo "Detected Python project with setup.py or pyproject.toml"
    echo "Installing package in development mode..."
    python -m pip install -e . 2>&1 || {
        echo "Failed to install package in development mode"
        exit 1
    }
    
    # Run pytest if available
    if command -v pytest &> /dev/null; then
        echo "Running tests with pytest..."
        pytest -v --tb=short 2>&1 || {
            echo "Some tests failed or no tests were found"
            exit 1
        }
    else
        echo "pytest not found, skipping tests"
    fi
else
    echo "No setup.py, pyproject.toml, or build.py found. Checking for alternative build systems..."
    
    # Check for Maven projects
    if [ -f "pom.xml" ]; then
        echo "Building Maven project..."
        mvn clean install -Drat.skip=true -Dlicense.skip=true 2>&1 || {
            echo "Maven build failed"
            exit 1
        }
    fi
    
    # Check for Node.js projects
    if [ -f "package.json" ]; then
        echo "Installing Node.js dependencies..."
        npm install 2>&1 || {
            echo "npm install failed"
            exit 1
        }
        
        if grep -q '"test"' package.json; then
            echo "Running npm tests..."
            npm test 2>&1 || {
                echo "npm tests failed"
                exit 1
            }
        fi
    fi
fi

echo "Build and test completed successfully!"