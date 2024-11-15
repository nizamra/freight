pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_REPO = 'nizamra'
        JAVA_APP_IMAGE = 'suseventsdetector'
        COMMIT_HASH = ''
        KUBECONFIG = 'C:\\Users\\HP\\.kube\\config'
    }

    stages {
        stage('Checkout Java App Code') {
            steps {
                // Checkout the Java app code from GitHub
                git url: 'https://github.com/nizamra/freight.git', branch: 'master'

                // Capture the Git commit hash
                script {
                    COMMIT_HASH = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                }
            }
        }

        stage('run code quality checks') {
            steps {
                sh "echo linter and formatter"
            }
        }

        stage('run automated tests') {
            steps {
                sh "echo mvn test"
            }
        }

        stage('Build Java App Docker Image') {
            steps {
                script {
                    // Build the Docker image for the Java app using the commit hash as the tag
                    docker.build("${DOCKERHUB_REPO}/${JAVA_APP_IMAGE}:${COMMIT_HASH}", '-f Dockerfile .')
                }
            }
        }

        stage('Push Java App Docker Image') {
            steps {
                script {
                    // Login to DockerHub securely and push the image
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                        // Perform Docker login
                        sh "echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USER} --password-stdin"

                        // Push the image with the commit hash tag
                        docker.image("${DOCKERHUB_REPO}/${JAVA_APP_IMAGE}:${COMMIT_HASH}").push()
                    }
                }
            }
        }

        stage('Checkout Helm Chart') {
            steps {
                // Clone the Helm chart repository
                git url: 'https://github.com/nizamra/hcharts.git', branch: 'master'
            }
        }

        stage('Deploy to Local Kubernetes with Helm') {
            steps {
                script {
                    // Set Helm release name and chart directory
                    def helmRelease = 'java-mysql-app'
                    def chartDir = 'java-app-helm-chart'
                    // Read SQL user and password from Jenkins credentials (ID = 'SQL')
                    withCredentials([usernamePassword(credentialsId: 'SQL', passwordVariable: 'SQL_PASS', usernameVariable: 'SQL_USER')]) {

                        // Run Helm upgrade or install with the KUBECONFIG set
                        withEnv(["KUBECONFIG=${KUBECONFIG}"]) {
                            sh """
                                kubectl config set-context --current --namespace=java-app-namespace
                                helm upgrade --install ${helmRelease} ${chartDir} \
                                --set app.image=${DOCKERHUB_REPO}/${JAVA_APP_IMAGE}:${COMMIT_HASH} \
                                --set app.env.mysqlHost=mysql-db \
                                --set app.env.mysqlDatabase=detector \
                                --set app.env.mysqlUsername=${SQL_user}\
                                --set app.env.mysqlPassword=${SQL_pass}
                            """
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
