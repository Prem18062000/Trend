pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = "prem18062000"
        IMAGE_NAME = "trend-app"
        AWS_REGION = "ap-south-1"
        EKS_CLUSTER_NAME = "trend-eks"
    }

    stages {

        stage("Checkout Source") {
            steps {
                checkout scm
            }
        }

        stage("Build Docker Image") {
            steps {
                sh """
                  sudo docker build -t ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest .
                """
            }
        }

        stage("Push Image to DockerHub") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "dockerhub-creds",
                    usernameVariable: "DOCKER_USER",
                    passwordVariable: "DOCKER_PASS"
                )]) {
                    sh """
                      echo ${DOCKER_PASS} | sudo docker login -u ${DOCKER_USER} --password-stdin
                      sudo docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage("Deploy to EKS") {
            steps {
                sh """
                  aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}
                  kubectl apply -f k8s/deployment.yaml
                  kubectl apply -f k8s/service.yaml
                """
            }
        }
    }
}
