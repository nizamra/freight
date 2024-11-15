pipeline {
    agent any

    environment {
        // DockerHub credentials
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_REPO = 'nizamra'
        JAVA_APP_IMAGE = 'suseventsdetector'
        DB_IMAGE = 'mysql'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from GitHub
                git url: 'https://github.com/nizamra/freight.git', branch: 'master'
            }
        }

        stage('Build Java App Docker Image') {
            steps {
                script {
                    // Build the Docker image for the Java app
                    docker.build("${DOCKERHUB_REPO}/${JAVA_APP_IMAGE}", '-f Dockerfile .')
                }
            }
        }

        stage('Build Database Docker Image') {
            steps {
                script {
                    // Build the Docker image for the SQL database
                    docker.build("${DOCKERHUB_REPO}/${DB_IMAGE}", '-f Dockerfile.database .')
                }
            }
        }

        stage('Push Java App Docker Image') {
            steps {
                script {
                    // Login to DockerHub securely using the withCredentials block
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                        // Perform the Docker login and push commands
                        sh "echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USER} --password-stdin || true"
                        docker.withRegistry('', "${DOCKERHUB_CREDENTIALS}") {
                            docker.image("${DOCKERHUB_REPO}/${JAVA_APP_IMAGE}").push("latest")
                        }
                    }
                }
            }
        }

    }

    post {
        always {
            cleanWs()
        }
    }
}
