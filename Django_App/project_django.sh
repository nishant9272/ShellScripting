#!/bin/bash

<< Comment
Deploy a Django app & handle the code for errors
Comment
code_clone() {
    echo "Cloning the Django app..."
    if [ -d "django-notes-app" ]; then
        echo "The code directory already exists. Skipping clone."
        cd django-notes-app || exit
    else
        git clone https://github.com/LondheShubham153/django-notes-app.git || {
            echo "Failed to clone the code."
            return 1
        }
    fi
}
install_requirements()
{
   echo "Installing the required dependencies ...."
    
    # Install Docker
    sudo apt-get install docker.io -y || {
        echo "Failed to install Docker ...."
        return 1
    }
    # Install Nginx
    sudo apt-get install nginx -y || {
        echo "Failed to install Nginx ...."
        return 1
    }
    echo "Dependencies installed successfully!"
}

required_restarts(){
    echo "performing restarts"
    sudo systemctl enable docker
    sudo systemctl enable nginx
    sudo systemctl restart docker
}

deploy() {
    echo "building & depploying the Django app..."
    docker build -t notes-app . && docker run -d -p 8000:8000 notes-app:latest || {
        echo "Failed to build and deploy the app."
        return 1
    }
}

echo ******** DEPLOYMENT STARTED ********
if ! code_clone; then
echo "changing directory"
#cd django-notes-app || exit
fi

if ! install_requirements; then
exit 1
fi

if ! required_restarts; then
exit 1
fi
if ! deploy; then
echo "deployment failed. Mailing the admin..."
exit 1
fi

echo ******** DEPLOYMENT Done ********