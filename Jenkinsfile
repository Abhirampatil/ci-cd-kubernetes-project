// Jenkinsfile is the pipeline's instruction file.tells Jenkins which stages to execute and which commands to run.) hence orchestarte
// The full CI/CD pipeline is here the jenkins orchestarte the whole flow (like downlaoding the latest repo code --> build docker image --> push docker image --> deploy to kubernetes--> verify deployment --> ) all of this stage-wise 

// Jenkins responsibilities ? :
// Trigger handling (Starts a pipeline when the GitHub webhook triggers the configured job.)
// source check out (Retrieves the repository contents from the configured main branch.)
// Image building
// Image versioning
// Registry publishing
// Deployment
// Deployment
// Reporting

// Important distinction: Github webhook triggers jenkins --> Jenkins runs the pipeline

pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'abhiram555'          // <- replace with your username
        IMAGE_NAME     = "${DOCKERHUB_USER}/ci-cd-k8s-app"
        IMAGE_TAG      = "v${BUILD_NUMBER}"
        KUBECONFIG     = '/var/lib/jenkins/.kube/config'
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $IMAGE_NAME:$IMAGE_TAG -t $IMAGE_NAME:latest .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                  usernameVariable: 'DH_USER',
                                                  passwordVariable: 'DH_PASS')]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker push $IMAGE_NAME:$IMAGE_TAG
                        docker push $IMAGE_NAME:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    sed "s|IMAGE_PLACEHOLDER|$IMAGE_NAME:$IMAGE_TAG|" k8s/deployment.yaml | kubectl apply -f -
                    kubectl apply -f k8s/service.yaml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    kubectl rollout status deployment/ci-cd-app --timeout=120s
                    kubectl get pods -o wide
                    kubectl describe deployment ci-cd-app | grep Image
                '''
            }
        }
    }

    post {
        success { echo "Deployed $IMAGE_NAME:$IMAGE_TAG" }
        failure { echo 'Pipeline failed. Check the stage logs above.' }
        always  { sh 'docker image prune -f || true' }
    }
}