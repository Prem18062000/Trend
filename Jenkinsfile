pipeline {
    agent any

    environment {
        DOCKERHUB_USER = '<dockerhub-username>'
        IMAGE_NAME     = 'trend-app'
        AWS_REGION     = 'ap-south-1'
        KUBE_CONFIG    = "$WORKSPACE/kubeconfig"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    sh """
                      docker build -t ${DOCKERHUB_USER}/${IMAGE_NAME}:latest .
                    """
                }
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                      echo "$PASS" | docker login -u "$USER" --password-stdin
                      docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    sh """
                      aws eks update-kubeconfig --name trend-eks --region ${AWS_REGION}
                      kubectl apply -f k8s/deployment.yaml
                      kubectl apply -f k8s/service.yaml
                    """
                }
            }
        }
    }
}
