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

# Check if this is an ONNX Runtime repository
if [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
    echo "Detected Python project with setup.py or pyproject.toml"
    
    # Check if this is ONNX Runtime (has build.py)
    if [ -f "build.py" ]; then
        echo "Detected ONNX Runtime repository with build.py"
        echo "Running build.py to generate build artifacts..."
        python build.py --config Release --build_wheel 2>&1 || {
            echo "Build failed"
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
        # Standard Python project - install in development mode
        echo "Installing package in development mode..."
        python -m pip install -e .
        
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
    fi
else
    echo "No setup.py or pyproject.toml found. Checking for alternative build systems..."
    
    # Check for Maven projects
    if [ -f "pom.xml" ]; then
        echo "Building Maven project..."
        mvn clean install -Drat.skip=true -Dlicense.skip=true
    fi
    
    # Check for Node.js projects
    if [ -f "package.json" ]; then
        echo "Installing Node.js dependencies..."
        npm install
        
        if grep -q '"test"' package.json; then
            echo "Running npm tests..."
            npm test
        fi
    fi
fi

echo "Build and test completed successfully!"