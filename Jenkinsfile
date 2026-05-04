pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "mulevenkatesh/multi-env-pipeline"
        DOCKER_TAG   = "${BUILD_NUMBER}"
        KUBECONFIG   = "/var/lib/jenkins/.kube/config"
        PATH         = "/usr/local/bin:/usr/bin:/bin"
    }

    stages {

        stage('1. Checkout') {
            steps {
                echo 'Pulling code from GitHub...'
                checkout scm
            }
        }

        stage('2. Maven Build') {
            steps {
                echo 'Maven build process...'
                sh 'mvn clean package'
            }
        }

        stage('3. Docker Build') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('4. Docker Push') {
            steps {
                echo 'Pushing Docker image...'
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub_creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login \
                            -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    '''
                }
            }
        }

        stage('5. Deploy to Dev') {
            steps {
                echo 'Deploying to Dev...'
                sh '''
                    kubectl get namespace dev || \
                        kubectl create namespace dev
                    kubectl apply -f k8s/dev/deployment.yaml -n dev
                    kubectl apply -f k8s/dev/service.yaml -n dev
                    kubectl rollout status deployment/multi-env-dev \
                        -n dev --timeout=90s
                '''
            }
        }

        stage('6. Health Check Dev') {
            steps {
                echo 'Health checking Dev...'
                sh 'bash scripts/health-check.sh dev 30081'
            }
        }

        stage('7. Deploy to Prod') {
            steps {
                echo 'Deploying to Prod...'
                sh '''
                    kubectl get namespace prod || \
                        kubectl create namespace prod
                    kubectl apply -f k8s/prod/deployment.yaml -n prod
                    kubectl apply -f k8s/prod/service.yaml -n prod
                    kubectl rollout status deployment/multi-env-prod \
                        -n prod --timeout=90s
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline SUCCESS - Dev and Prod deployed!'
        }
        failure {
            echo 'Pipeline FAILED - running rollback...'
            sh 'bash scripts/rollback.sh'
        }
    }
}
