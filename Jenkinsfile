pipeline {
    agent any

    stages {


        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Use kubectl commands directly
                    sh 'kubectl'
                    // Replace 'pod-name' with your actual pod name
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
