pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = "prem18062000"
        IMAGE_NAME = "trend-app"

        AWS_REGION = "ap-south-1"
        EKS_CLUSTER_NAME = "trend-eks"

        TF_DIR = "tf"
    }

    stages {

        stage("Checkout Source") {
            steps {
                checkout scm
            }
        }

        stage("Terraform Init") {
            steps {
                dir("${TF_DIR}") {
                    sh """
                      terraform init -input=false
                    """
                }
            }
        }

        stage("Terraform Plan") {
            steps {
                dir("${TF_DIR}") {
                    sh """
                      terraform plan -out=tfplan
                    """
                }
            }
        }

        stage("Terraform Apply (Manual Approval)") {
            when {
                beforeInput true
                expression { return env.BRANCH_NAME == 'main' }
            }
            input {
                message "Apply Terraform changes?"
                ok "Apply"
            }
            steps {
                dir("${TF_DIR}") {
                    sh """
                      terraform apply -auto-approve tfplan
                    """
                }
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
                  aws eks update-kubeconfig \
                    --region ${AWS_REGION} \
                    --name ${EKS_CLUSTER_NAME}

                  kubectl apply -f k8s/
                """
            }
        }
    }
}
