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

        stage('Configure AWS1') {
            steps {
                script {

                    
                    sh "docker build -t 489994096722.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/fastapi-helloworld-project:asd1 -f ./fastapi/Dockerfile ./fastapi/"
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin 489994096722.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker push 489994096722.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/fastapi-helloworld-project:asd1"
                }
            }
        }



        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'github-sa-token', serverUrl: 'https://3AE5127E3A8CA56D9ED6A6BCEBC630F6.yl4.us-west-1.eks.amazonaws.com']) {
                sh 'helm upgrade fastapi-hello-world ./kubernetes/charts/fastapi-hello-world --values ./kubernetes/charts/fastapi-hello-world/values.yaml --set image.tag=d12345'

                }
            }
        }


    }
}
