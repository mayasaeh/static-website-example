@Library('slack-notifier')_
pipeline {
    environment {
        IMAGE_NAME = "mayas213/static-website"
        IMAGE_TAG = "${BUILD_TAG}"
        CONTAINER_NAME = "static-website"
        DOCKERHUB_PASSWORD = credentials('dockerhub_password')
        PROD_HOST = "52.202.78.159"
    }
    agent none

    stages{
        stage('Build image') {
            agent any
            steps {
                script {
                    sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
                }
            }
        }

        stage('Run container') {
            agent any
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    script {
                        sh '''
                            sudo docker stop ${CONTAINER_NAME}
                            sudo docker rm ${CONTAINER_NAME}
                        '''
                    }
                }
                script {
                    sh '''
                        docker run -d --name ${CONTAINER_NAME} -p 8081:80 ${IMAGE_NAME}:${IMAGE_TAG}
                        sleep 5
                    '''
                }
                script {
                    sh '''
                        curl localhost:8081 | grep -q "Contact"
                    '''
                }
            }
        }

        stage('Test image') {
            agent any
            steps {
                script {
                    sh '''
                    '''
                }
            }
        }

        stage('Delete container') {
            agent any
            steps {
                script {
                    sh '''
                        docker stop ${CONTAINER_NAME}
                        docker rm ${CONTAINER_NAME}
                    '''
                }
            }
        }

        stage ('Push image on DockerHub') {
        agent any
            steps{
                script {
                    sh '''
                        docker login -u mayas213 -p ${DOCKERHUB_PASSWORD}
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker rmi ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage ('Run container on PROD HOST'){
            agent {label 'prod'}
            steps{
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    script {
                        sh '''
                            sudo docker stop ${CONTAINER_NAME}
                            sudo docker rm ${CONTAINER_NAME}
                        '''
                    }
                }
                script {
                    sh '''
                        sudo docker run -d --name ${CONTAINER_NAME} -p 8080:80 ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    script {
                        sh '''
                            curl http://localhost:8080 | grep -q "Contact"
                            curl http://${PROD_HOST}:8080 | grep -q "Contact"
                        '''
                    }
                }
            }
        }
    }

    post {
        always{
            script{
                slackNotifier currentBuild.result
            }
        }
    }
}