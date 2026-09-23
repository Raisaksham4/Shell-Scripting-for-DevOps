#!/bin/bash

<< task
This script deploys a Django application and handles
errors that may occur during the deployment process.
task

code_clone() {
    echo "Checking Django application repository..."

    if [ -d "django-notes-app" ]; then
        echo "Repository already exists."
    else
        echo "Cloning the Django application repository..."

        git clone https://github.com/LondheShubham153/django-notes-app.git || {
            echo "Error: Failed to clone repository."
            return 1
        }
    fi

    cd django-notes-app || {
        echo "Error: Failed to change directory."
        return 1
    }
}

required_restarts() {
    echo "Restarting Docker service..."

    sudo systemctl enable docker
    sudo systemctl restart docker
}

cleanup() {
    echo "Cleaning up previous deployment..."

    docker compose down 2>/dev/null || true

    docker rm -f condescending_shirley 2>/dev/null || true
}

deploy() {
    echo "Deploying the Django application..."

    docker compose up --build -d
}

if ! code_clone; then
    echo "Error: Repository setup failed."
    exit 1
fi

if ! required_restarts; then
    echo "Error: Failed to restart Docker."
    exit 1
fi

if ! cleanup; then
    echo "Error: Failed to clean up previous deployment."
    exit 1
fi

if ! deploy; then
    echo "Error: Failed to deploy the Django application."
    exit 1
fi

echo "===================================="
echo "Django application deployed!"
echo "===================================="
echo "Application: http://localhost:8000"