pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'  // Specify your AWS region
        AWS_CREDENTIALS = credentials('AWS_ROLE')  // Replace with your AWS credentials ID
        AWS_SESSION_TOKEN = withCredentials([credentials('AWS_SESSION_TOKEN')]) {
            return env.AWS_SESSION_TOKEN
        }
    }

    stages {


        stage('Install kubectl') {
            steps {
                // Install kubectl (if not already installed)
                sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl'
                sh 'chmod +x ./kubectl'
                sh './kubectl'

            }
        }


        stage('Configure AWS') {
            steps {
                script {
                    sh "aws configure set aws_access_key_id ${AWS_CREDENTIALS_USR}"
                    sh "aws configure set aws_secret_access_key ${AWS_CREDENTIALS_PSW}"
                    sh "aws configure set aws_session_token ${AWS_SESSION_TOKEN}"
                    sh "aws configure set region ${AWS_DEFAULT_REGION}"
                    sh "aws sts get-caller-identity"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'github-sa-token', serverUrl: 'https://3AE5127E3A8CA56D9ED6A6BCEBC630F6.yl4.us-west-1.eks.amazonaws.com']) {
                sh './kubectl get pod'
                sh 'helm version --client'
                sh 'docker ps'
                }
            }
        }


        stage('Build') {
            steps {
                echo 'Building...'
                // Your build steps here
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
                // Your test steps here
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                // Your deployment steps here
            }
        }
    }
}
