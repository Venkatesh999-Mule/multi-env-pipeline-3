pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "mulevenkatesh/multi-env-pipeline"
        DOCKER_TAG = "${BUILD_NUMBER}"
        KUBECONFIG = "var/lib/jenkins/.kube/config"
        PATH         = "/usr/local/bin:/usr/bin:/bin"

    }

    stages{
        stage('1. CHECKOUT'){
            steps {
                sh 'echo "pulling code from GitHub"'
                checkout scm
            }
        }
        stage('2. MAVEN '){
            steps {
                sh 'echo "MAVEN build process ... "'
                sh 'mvn clean install'
            }
        }
        stage('3. Docker Build') {
            steps{
                sh 'echo "Building Docker image"'
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }
        stage('4. Docker image Push '){
            steps {
                sh 'echo "Pushing Docker Image" '
                withCredentials([usernamePassword(
                    credentialsId : 'dockerhub_creds',
                    usernameVariable : 'DOCKER_USER',
                    passwordVariable : 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login \
                        -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    '''
                }
            }
        }
        stage('5. Deploy to Dev '){
            steps {
                sh 'echo "Deployment to dev team "'
                sh 'kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -'
                sh "sed -i 's|IMAGE_TAG|${DOCKER_TAG}|g' k8s/dev/deployment.yaml"
                sh 'kubectl apply -f k8s/dev/deployment.yaml -n dev'
                sh 'kubectl apply -f k8s/dev/service.yaml -n dev'
                sh 'kubectl rollout status deployment/multi-env-dev -n dev --timeout=90s'
            }
        }
        stage('6. Health Check - Dev') {
            steps {
                echo 'Checking Dev environment health...'
                sh 'bash scripts/health-check.sh dev 30081'
            }
        }
        stage('7. Deploy to prod') {
            steps {
                echo 'Deploying to Prod environment...'
                sh 'kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -'
                sh "sed -i 's|IMAGE_TAG|${DOCKER_TAG}|g' k8s/prod/deployment.yaml"
                sh 'kubectl apply -f k8s/prod/deployment.yaml -n prod'
                sh 'kubectl apply -f k8s/prod/service.yaml -n prod'
                sh 'kubectl rollout status deployment/multi-env-prod -n prod --timeout=90s'
            }
        }
    }
    post {
        success {
            echo 'Pipeline SUCCESS - deployed to Dev and Prod!'
        }
        failure {
            echo 'Pipeline FAILED - running rollback...'
            sh 'bash scripts/rollback.sh'
        }
    }
}