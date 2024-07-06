pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-west-1'  // Specify your AWS region
        AWS_CREDENTIALS_USR = credentials('access_key_id')
        AWS_CREDENTIALS_PSW = credentials('secret_access_key')
        AWS_SESSION_TOKEN = credentials('AWS_SESSION_TOKEN')
    }

    stages {
        stage('Install kubectl') {
            steps {
                script {
                    def pipelineFunctions = load 'pipelineFunctions.groovy'
                    pipelineFunctions.installKubectl()
                }
            }
        }

        stage('Configure AWS') {
            steps {
                script {
                    def pipelineFunctions = load 'pipelineFunctions.groovy'
                    pipelineFunctions.configureAWS()
                }
            }
        }

        stage('Build Docker Image and Push to ECR') {
            steps {
                script {
                    def pipelineFunctions = load 'pipelineFunctions.groovy'
                    pipelineFunctions.buildAndPushDockerImage()
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def pipelineFunctions = load 'pipelineFunctions.groovy'
                    pipelineFunctions.deployToKubernetes()
                }
            }
        }
    }
}
