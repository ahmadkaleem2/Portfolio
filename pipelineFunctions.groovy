// pipelineFunctions.groovy

def installKubectl() {
    if (!isCommandAvailable('kubectl')) {
        downloadKubectl()
        makeExecutable('./kubectl')
    }
    executeCommand('./kubectl version --client')
}

def configureAWS() {
    executeCommand("aws configure set aws_access_key_id ${env.AWS_CREDENTIALS_USR}")
    executeCommand("aws configure set aws_secret_access_key ${env.AWS_CREDENTIALS_PSW}")
    executeCommand("aws configure set aws_session_token ${env.AWS_SESSION_TOKEN}")
    executeCommand("aws configure set region ${env.AWS_DEFAULT_REGION}")
}

def buildAndPushDockerImage() {
    def dockerImage = "489994096722.dkr.ecr.${env.AWS_DEFAULT_REGION}.amazonaws.com/fastapi-helloworld-project:${env.BUILD_ID}"
    executeCommand("docker build -t ${dockerImage} -f ./fastapi/Dockerfile ./fastapi/")
    executeCommand("aws ecr get-login-password --region ${env.AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin 489994096722.dkr.ecr.${env.AWS_DEFAULT_REGION}.amazonaws.com")
    executeCommand("docker push ${dockerImage}")
}

def deployToKubernetes() {
    withKubeConfig([credentialsId: 'github-sa-token', serverUrl: 'https://3AE5127E3A8CA56D9ED6A6BCEBC630F6.yl4.us-west-1.eks.amazonaws.com']) {
        executeCommand("helm upgrade fastapi-hello-world ./kubernetes/charts/fastapi-hello-world --values ./kubernetes/charts/fastapi-hello-world/values.yaml --set image.tag=${env.BUILD_ID}")
    }
}

// Helper functions

def isCommandAvailable(command) {
    return executeCommand("command -v ${command}", true) == 0
}

def downloadKubectl() {
    executeCommand("curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl")
}

def makeExecutable(filePath) {
    executeCommand("chmod +x ${filePath}")
}

def executeCommand(command, returnStatus = false) {
    if (returnStatus) {
        return sh(script: command, returnStatus: true)
    } else {
        sh(script: command)
    }
}

return this
