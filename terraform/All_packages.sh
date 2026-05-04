#!/bin/bash

# Updating :
echo "=============================================      Updating      ==============================================="
sudo yum update -y 

# Install Java :
echo "========================================      Installing Java     ==============================================="
sudo yum install java-21-amazon-corretto -y

# Install git :
echo "========================================       Installing git       =============================================="
sudo yum install git -y

# Install maven :
echo "========================================     Installing Maven      =============================================="
sudo yum install maven -y

# Install Jenkins :
echo "========================================     Installing Jenkins      =============================================="
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/rpm-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key
sudo yum upgrade -y
sudo yum install jenkins -y 
sudo systemctl start jenkins


#Install Docker :
echo "========================================     Installing Docker      =============================================="
sudo yum install docker -y
sudo systemctl start docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Install kubectl
echo "========================================     Installing Kubeclt     =============================================="
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Minikube
echo "========================================     Installing Minikube      =============================================="
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube with Docker driver
echo "========================================     Starting Minikube      =============================================="
minikube start --driver=docker


sudo mkdir -p /var/lib/jenkins/.kube
sudo cp ~/.kube/config /var/lib/jenkins/.kube/config
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
sudo mkdir -p /var/lib/jenkins/.minikube/profiles/minikube
sudo cp ~/.minikube/ca.crt \
    /var/lib/jenkins/.minikube/ca.crt
sudo cp ~/.minikube/profiles/minikube/client.crt \
    /var/lib/jenkins/.minikube/profiles/minikube/client.crt
sudo cp ~/.minikube/profiles/minikube/client.key \
    /var/lib/jenkins/.minikube/profiles/minikube/client.key
sudo chown -R jenkins:jenkins /var/lib/jenkins/.minikube
sudo sed -i \
    's|/home/ec2-user/.minikube|/var/lib/jenkins/.minikube|g' \
    /var/lib/jenkins/.kube/config

echo "================================       SUCCESSFULLY INSTALL ALL PACKAGES       ======================================"
echo "==================================    !!  READY TO ACCESS !!                  ======================================="

#Jenkins Address link & Password :
echo "@@@@@@@@@@@@@     JENKINS URL : '  http://$(curl ifconfig.me):8080  '   @@@@@@@@@@@@@@@@"
echo "Admin Password:$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"

#Checking All packages version :
echo "===java vesrion==="
java -version
echo "===maven==="
mvn -version
echo "===git vesrion==="
git --version
echo "===jenkins vesrion==="
jenkins --version
echo "===docker vesrion==="
docker --version
echo "===kubernets vesrion==="
kubectl version --client

#To restart dockers:
newgrp docker



