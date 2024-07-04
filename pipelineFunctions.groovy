// pipelineFunctions.groovy

def installKubectl() {
    sh '''
        if ! command -v kubectl &> /dev/null; then
            curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl
            chmod +x ./kubectl
        fi
        ./kubectl version --client
    '''
}

def configureAWS() {
    sh '''
        aws configure set aws_access_key_id ${AWS_CREDENTIALS_USR}
        aws configure set aws_secret_access_key ${AWS_CREDENTIALS_PSW}
        aws configure set aws_session_token ${AWS_SESSION_TOKEN}
        aws configure set region ${AWS_DEFAULT_REGION}
    '''
}

def buildAndPushDockerImage() {
    def dockerImage = "489994096722.dkr.ecr.${env.AWS_DEFAULT_REGION}.amazonaws.com/fastapi-helloworld-project:${env.BUILD_ID}"
    sh """
        docker build -t ${dockerImage} -f ./fastapi/Dockerfile ./fastapi/
        aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin 489994096722.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
        docker push ${dockerImage}
    """
}

def deployToKubernetes() {
    withKubeConfig([credentialsId: 'github-sa-token', serverUrl: 'https://3AE5127E3A8CA56D9ED6A6BCEBC630F6.yl4.us-west-1.eks.amazonaws.com']) {
        sh """
            helm upgrade fastapi-hello-world ./kubernetes/charts/fastapi-hello-world \
            --values ./kubernetes/charts/fastapi-hello-world/values.yaml \
            --set image.tag=${env.BUILD_ID}
        """
    }
}

return this
