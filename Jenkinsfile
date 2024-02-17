pipeline {
     agent any
     stages {
         
        stage('Get Code') {
            steps {
                // Obtener código del repo de la rama develop
                git branch: 'master', url: 'https://github.com/VIRIATO80/unir_todo_repo.git'
                
                // Guardar el código en un stash llamado 'code'
                stash name: 'code', includes: '**/*'                
            }
        }         
         
        stage('SAM Deploy'){
            steps{
                script {
                    echo 'Initiating Deployment'
                    sh '''
                        sam deploy \\
                            --force-upload \\
                            --stack-name todo-list-aws-production \\
                            --region us-east-1 \\
                            --resolve-s3 \\
                            --config-env production \\
                            --no-fail-on-empty-changeset \\
                            --capabilities CAPABILITY_IAM \\
                            --no-confirm-changeset \\
                        '''
                     // Obtener la URL base de la API después del despliegue
                    def BASE_URI = sh(script: "aws cloudformation describe-stacks --stack-name todo-list-aws-production --query 'Stacks[0].Outputs[?OutputKey==`BaseUrlApi`].OutputValue' --region us-east-1 --output text", returnStdout: true).trim()
                    // Almacenar la URL base de la API como una variable de entorno
                    env.BASE_URI = BASE_URI
                }
                    
            }
        }  
        
        stage('Integration Tests'){
            agent {
                label 'pytest'
            }             
            steps{
                withPythonEnv('/usr/bin/python3.10') {
                    script {
                        // Recuperar el código del stash llamado 'code'
                        unstash 'code'
                        
                        echo 'Initiating Integration Tests'
                        // Ejecutar pytest de Python
                        sh """
                            python -m pip install pytest
                            python -m pip install requests
                            export BASE_URI=${env.BASE_URI}
                            pytest -s test/integration/todoApiTest.py
                        """
                    }
                }
            }
        }
        
     }
     
    post { 
        always { 
            echo 'Clean env: delete dir'
            cleanWs()
        }
    }         
}