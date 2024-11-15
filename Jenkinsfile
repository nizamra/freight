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
                        docker.withRegistry('https://registry.hub.docker.com', "${DOCKERHUB_CREDENTIALS}") {
                            docker.image("${DOCKERHUB_REPO}/${JAVA_APP_IMAGE}").push("latest")
                        }
                    }
                }
            }
        }



        stage('Push Database Docker Image') {
            steps {
                script {
                    // Push the SQL database image
                    docker.withRegistry('', "${DOCKERHUB_CREDENTIALS}") {
                        docker.image("${DOCKERHUB_REPO}/${DB_IMAGE}").push("latest")
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
