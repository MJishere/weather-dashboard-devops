pipeline {
  agent any

  environment {
    AWS_REGION = "us-east-1"
    ECR_BACKEND = "weather_dashboard_backend"
    ECR_FRONTEND = "weather_dashboard_frontend"
    EKS_CLUSTER = "weather_dashboard_eks"
  }

  stages {
    stage('Clean Workspace') {
      steps { 
        cleanWs() 
      }
    }

    stage('Checkout Code') {
      steps { 
        checkout scm 
      }
    }

    stage('Build Docker Images') {
      steps {
        // Pass OPENWEATHER_API_KEY to backend build, backend URL to frontend build
        withCredentials([string(credentialsId: 'OPENWEATHER_API_KEY', variable: 'OPENWEATHER_API_KEY')]) {
          sh """
            docker build --build-arg OPENWEATHER_API_KEY=${OPENWEATHER_API_KEY} -t ${ECR_BACKEND}:latest ./backend
            docker build --build-arg VITE_API_URL=/api -t ${ECR_FRONTEND}:latest ./frontend
          """
        }
      }
    }

    stage('Login to ECR & Push Images') {
      steps {
        withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-devops-creds' ]]) {
          script {
            def accountId = sh(script: "aws sts get-caller-identity --query 'Account' --output text", returnStdout: true).trim()
            sh """
              aws ecr get-login-password --region ${AWS_REGION} | \
                docker login --username AWS --password-stdin ${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com

              docker tag ${ECR_BACKEND}:latest ${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_BACKEND}:latest
              docker tag ${ECR_FRONTEND}:latest ${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_FRONTEND}:latest

              docker push ${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_BACKEND}:latest
              docker push ${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_FRONTEND}:latest
            """
          }
        }
      }
    }

    stage('Deploy to EKS') {
      steps {
        withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-devops-creds' ]]) {
          script {
            // Update kubeconfig using AWS credentials
            sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}"
    
            // Create Kubernetes secret for OPENWEATHER_API_KEY
            withCredentials([string(credentialsId: 'OPENWEATHER_API_KEY', variable: 'OPENWEATHER_API_KEY')]) {
              sh """
                kubectl create secret generic openweather-secret \
                  --from-literal=OPENWEATHER_API_KEY=${OPENWEATHER_API_KEY} \
                  --dry-run=client -o yaml | kubectl apply -f -
              """
            }
    
            // Get AWS account ID and store in environment variable for global use
            env.AWS_ACCOUNT_ID = sh(
              script: "aws sts get-caller-identity --query 'Account' --output text",
              returnStdout: true
            ).trim()
    
            // List of all Kubernetes YAMLs (deployments + services)
            def k8sFiles = [
              "k8s/backend-deployment.yaml",
              "k8s/frontend-deployment.yaml",
              "k8s/backend-service.yaml",
              "k8s/frontend-service.yaml"
            ]
    
            // Apply all YAML files
            for (file in k8sFiles) {
              sh """
                sed -i 's|<AWS_ACCOUNT_ID>|${AWS_ACCOUNT_ID}|g' $file
                sed -i 's|\\\${AWS_REGION}|${AWS_REGION}|g' $file
                kubectl apply -f $file
              """
            }
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
      echo "✅ Deployment successful!" 
    }
    failure { 
      echo "❌ Deployment failed. Check console output." 
    }
  }
}
