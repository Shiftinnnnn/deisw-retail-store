pipeline {
    agent any

    tools {
        maven 'MAVEN_3_9_16'
        jdk 'JDK_26'
    }

    environment {
        REGISTRY_USER = "sebastiannnn"
        STUDENT_CODE  = "u202310199"
        IMAGE_NAME    = "retail-store-u202310199"
        TAG           = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('1. Compile Project') {
            steps {
                withMaven(maven: 'MAVEN_3_9_16') {
                    sh 'mvn clean compile'
                }
            }
        }

        stage('2. Validate Checkstyle') {
            steps {
                withMaven(maven: 'MAVEN_3_9_16') {
                    sh 'mvn checkstyle:check'
                }
            }
        }

        stage('3. Validate Unit Tests') {
            steps {
                withMaven(maven: 'MAVEN_3_9_16') {
                    sh 'mvn test'
                }
            }
        }

        stage('4. Validate Test Coverage') {
            steps {
                withMaven(maven: 'MAVEN_3_9_16') {
                    sh 'mvn clean verify jacoco:report'
                    sh 'mvn jacoco:check'
                }
            }
        }

        stage('5. SonarQube Analysis') {
            steps {
                withMaven(maven: 'MAVEN_3_9_16') {
                    withSonarQubeEnv('MiSonarServer') {
                        sh '''
                            mvn clean verify sonar:sonar \
                            -Dsonar.projectKey=deisw-language-reference \
                            -Dsonar.host.url=$SONAR_HOST_URL \
                            -Dsonar.login=$SONAR_AUTH_TOKEN
                        '''
                    }
                }

                script {
                    timeout(time: 10, unit: 'MINUTES') {
                        def qg = waitForQualityGate()

                        if (qg.status != 'OK') {
                            error "El pipeline se ha detenido porque el código no superó el Quality Gate de SonarQube. Estado: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage('6. Construir y Publicar Imagen Docker') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'DOCKER_HUB_CREDENTIALS',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    script {
                        echo "Iniciando sesión en Docker Hub..."
                        sh "echo '${DOCKER_PASS}' | docker login -u '${DOCKER_USER}' --password-stdin"

                        echo "Construyendo imagen optimizada AMD64..."
                        sh """
                            docker buildx build \
                            --platform linux/amd64 \
                            -t ${REGISTRY_USER}/${IMAGE_NAME}:${TAG} \
                            -t ${REGISTRY_USER}/${IMAGE_NAME}:latest \
                            --push .
                        """
                    }
                }
            }
        }
    }
}
