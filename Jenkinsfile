pipeline {
    agent any

    tools {
        maven 'MAVEN_3_9_16'
        jdk 'JDK_26'
    }

    environment {
        REGISTRY_USER = "sebastiannnn"
        STUDENT_CODE  = "u202310199"
        IMAGE_NAME    = "retail-store-${STUDENT_CODE}"
        TAG           = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Compile Project') {
            steps {
                withMaven(maven: 'MAVEN_3_9_16') {
                    sh 'mvn clean compile'
                }
            }
        }

        stage('Validate Checkstyle') {
            steps {
                withMaven(maven: 'MAVEN_3_9_16') {
                    sh 'mvn checkstyle:check'
                }
            }
        }

        stage('Validate Unit Tests') {
            steps {
                withMaven(maven: 'MAVEN_3_9_16') {
                    sh 'mvn test'
                }
            }
        }

        stage('Validate Test Coverage') {
            steps {
                withMaven(maven: 'MAVEN_3_9_16') {
                    sh 'mvn clean verify jacoco:report'
                    sh 'mvn jacoco:check'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withMaven(maven: 'MAVEN_3_9_16') {
                    withSonarQubeEnv('MiSonarServer') {
                        sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=deisw-language-reference'
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

        stage('Construir y Publicar Imagen Docker') {
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

                        echo "Construyendo y publicando imagen Docker..."
                        sh """
                            docker buildx build \
                            --platform linux/amd64 \
                            -t ${REGISTRY_USER}/${IMAGE_NAME}:${TAG} \
                            --push .
                        """
                    }
                }
            }
        }
    }
}
