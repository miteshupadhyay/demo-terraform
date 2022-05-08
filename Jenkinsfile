def dockerImage=""
def applicationName="Bank-Service"

pipeline {
    agent any
    environment{
        AWS_ACCOUNT_ID="819754052673"
        AWS_DEFAULT_REGION="ap-south-1"
        IMAGE_REPO_NAME="bank-service-api"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }
    tools {
        terraform 'Terraform v1.0.11'
        maven '3.8.3'
        dockerTool 'docker'
    }
    stages {
        // Checkout Code from Git Repository
        stage ("checkout from GIT") {
            steps {
                git branch: 'main', credentialsId: 'Guthub_Cred', url: 'https://github.com/miteshupadhyay/terraform'
                	script {
                         GIT_COMMIT_WITH_V = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
                    }
            }
        }

        // Build and Compile Code
        stage ("Compile & Build") {
            steps {
                sh "mvn clean package"
            }
        }

        // Building Docker image
        stage('Building Docker image') {
           steps{
              script {
                   dockerImage = docker.build "${IMAGE_REPO_NAME}:${GIT_COMMIT_WITH_V}"
                }
              }
            }

        // Once Image gets Build Login to ECR Repository
        stage('Logging into AWS ECR') {
            steps {
                script {
                sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                }

            }
        }

        // Uploading Docker image into AWS ECR
         stage('Pushing Docker Image to ECR') {
                 steps{
                     script {
                            sh "docker tag ${IMAGE_REPO_NAME}:${GIT_COMMIT_WITH_V} ${REPOSITORY_URI}:$GIT_COMMIT_WITH_V"
                            sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${GIT_COMMIT_WITH_V}"
                     }
                    }
                  }

        // Terraform Plan - VPC

          stage ("terraform Plan - VPC") {
                    steps {
                          dir('terraform/vpc_infra')
                          {
                                sh 'terraform init'
                                sh 'terraform plan -var-file="production.tfvars"'
                          }
                    }
                }
         // VPC CreationC
                 stage ("VPC Creation") {
                            steps {
                                  dir('terraform/vpc_infra')
                                  {
                                    sh 'terraform apply -auto-approve -var-file="production.tfvars"'
                                  }
                            }
                        }
        // Terraform Plan - ECS
                 stage ("terraform Plan - ECS") {
                            steps {
                                  dir('terraform/ecs_infra')
                                  {
                                        sh 'terraform init'
                                        sh 'terraform plan -var-file="production.tfvars"'
                                  }
                            }
                        }

         // ECS Setup
         stage ("ECS Setup") {
                    steps {
                          dir('terraform/ecs_infra')
                          {
                            sh 'terraform apply -auto-approve -var-file="production.tfvars"'
                          }
                    }
                }
         // ECS Task Setup
         stage ("terraform Plan - Task Setup") {
                   steps {
                       dir('terraform/Task_Deployment')
                        {
                        sh 'terraform init'
                        script{
                               sh "terraform plan -var-file='production.tfvars' -var docker_image_url=${REPOSITORY_URI}:$GIT_COMMIT_WITH_V"
                           }
                        }
                  }
             }
         // ECS Task Creation
         stage ("Task Setup and Deployment") {
                    steps {
                          dir('terraform/Task_Deployment')
                          {
                        script{
                           sh "terraform apply -auto-approve -var-file='production.tfvars' -var docker_image_url=${REPOSITORY_URI}:$GIT_COMMIT_WITH_V"
                         }
                      }
                    }
                }
        }
}