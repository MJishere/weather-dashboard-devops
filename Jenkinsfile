pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        ECR_REPO_BACKEND = "weather_dashboard_backend"
        ECR_REPO_FRONTEND = "weather_dashboard_frontend"
        EKS_CLUSTER_NAME = "weather_dashboard_eks"
        APP_NAME = "weather_dashboard"
    }

    stages {
        stage('Clean Workspace') {
            steps { cleanWs() }
        }

        stage("Checkout Code") {
            steps {
                checkout scm
            }
        }

        stage("Build Docker Images") {
            steps {
                withCredentials([string(credentialsId: 'OPENWEATHER_API_KEY', variable: 'OPENWEATHER_API_KEY')]) {
                    script {
                        sh """
                        docker build --build-arg OPENWEATHER_API_KEY=${OPENWEATHER_API_KEY} \
                        -t ${ECR_REPO_BACKEND}:latest ./backend
                        """

                        sh """
                        docker build --build-arg VITE_API_URL=http://backend-service:5000 \
                        -t ${ECR_REPO_FRONTEND}:latest ./frontend
                        """
                    }
                }
            }
        }

        stage("Login to AWS ECR and Push Images") {
            steps {
                withAWS(credentials: 'aws-devops-creds', region: "${AWS_REGION}") {
                    script {
                        def accountId = sh(script: "aws sts get-caller-identity --query 'Account' --output text", returnStdout: true).trim()

                        sh """
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com

                        docker tag ${ECR_REPO_BACKEND}:latest ${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_BACKEND}:latest
                        docker tag ${ECR_REPO_FRONTEND}:latest ${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_FRONTEND}:latest

                        docker push ${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_BACKEND}:latest
                        docker push ${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_FRONTEND}:latest
                        """
                    }
                }
            }
        }

        stage("Deploy to EKS") {
            steps {
                withAWS(credentials: 'aws-devops-creds', region: "${AWS_REGION}") {
                    script {
                        sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}"

                        // Inject API key as Kubernetes secret
                        withCredentials([string(credentialsId: 'OPENWEATHER_API_KEY', variable: 'OPENWEATHER_API_KEY')]) {
                            sh """
                            kubectl create secret generic openweather-secret \
                                --from-literal=OPENWEATHER_API_KEY=${OPENWEATHER_API_KEY} \
                                --dry-run=client -o yaml | kubectl apply -f -
                            """
                        }

                        def accountId = sh(script: "aws sts get-caller-identity --query 'Account' --output text", returnStdout: true).trim()

                        // Deploy backend
                        sh """
                        sed -i 's|<AWS_ACCOUNT_ID>|${accountId}|g' k8s/backend-deployment.yaml
                        sed -i 's|\\\${AWS_REGION}|${AWS_REGION}|g' k8s/backend-deployment.yaml
                        kubectl apply -f k8s/backend-deployment.yaml
                        """

                        // Deploy frontend
                        sh """
                        sed -i 's|<AWS_ACCOUNT_ID>|${accountId}|g' k8s/frontend-deployment.yaml
                        sed -i 's|\\\${AWS_REGION}|${AWS_REGION}|g' k8s/frontend-deployment.yaml
                        kubectl apply -f k8s/frontend-deployment.yaml
                        """
                    }
                }
            }
        }

        stage('Docker Cleanup') {
            steps {
                sh 'docker system prune -af'
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful! Application is live on EKS."
        }
        failure {
            echo "❌ Deployment failed. Check Jenkins console logs for more details."
        }
    }
}
