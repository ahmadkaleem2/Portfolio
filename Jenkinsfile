pipeline {
    agent any

    stages {


        stage('Install kubectl') {
            steps {
                // Install kubectl (if not already installed)
                sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl'
                sh 'chmod +x ./kubectl'
                sh './kubectl'
            }
        }


        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'github-sa-token', serverUrl: 'https://3AE5127E3A8CA56D9ED6A6BCEBC630F6.yl4.us-west-1.eks.amazonaws.com']) {
                sh 'kubectl get pod'
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
