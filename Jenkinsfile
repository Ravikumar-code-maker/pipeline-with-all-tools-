pipeline {

    agent any

    environment {

        IMAGE_NAME = "dockerhubuser/myapp:v1"
    }

    stages {

        stage('Clone Code') {

            steps {

                git 'https://github.com/user/project.git'
            }
        }

        stage('Run Deployment') {

            steps {

                withCredentials([

                    usernamePassword(
                        credentialsId: 'docker-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    ),

                    usernamePassword(
                        credentialsId: 'nexus-creds',
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASS'
                    ),

                    file(
                        credentialsId: 'gcp-key',
                        variable: 'GCP_KEY'
                    ),

                    file(
                        credentialsId: 'kubeconfig',
                        variable: 'KUBECONFIG_FILE'
                    ),

                    sshUserPrivateKey(
                        credentialsId: 'ansible-ssh',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )

                ]) {

                    sh 'chmod +x scripts/deploy.sh'

                    sh './scripts/deploy.sh'
                }
            }
        }
    }

    post {

        success {

            echo 'Pipeline Successful'
        }

        failure {

            echo 'Pipeline Failed'
        }
    }
}
