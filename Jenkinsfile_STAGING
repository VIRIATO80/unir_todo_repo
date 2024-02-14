pipeline {
     agent any
     stages {
         
        stage('Get Code') {
            steps {
                // Obtener código del repo de la rama develop
                git branch: 'develop', url: 'https://github.com/VIRIATO80/unir_todo_repo.git'
            }
        }         
         
        stage('Prepare environment') {
            steps {
                withPythonEnv('/usr/bin/python3.10') {
                    // Creates the virtualenv before proceeding
                    sh 'bash ./pipelines/PIPELINE-FULL-STAGING/setup.sh'
                }
            }
        }         

        
        stage('Static') {
            steps {
                withPythonEnv('/usr/bin/python3.10') {
                    sh '''
                        . todo-list-aws/bin/activate
                        set -x                    
                        flake8 --exit-zero --format=pylint src/*.py > flake8.out
                    '''
                    recordIssues tools: 
                        [flake8(name: 'Flake8', pattern: 'flake8.out')]
                }
            }
        }        
        
        stage('Security') {
            steps {
                withPythonEnv('/usr/bin/python3.10') {                
                    sh '''
                        . todo-list-aws/bin/activate
                        set -x
                        bandit --exit-zero -r src/*.py -f custom -o bandit.out --severity-level medium --msg-template "{abspath}:{line}: [{test_id} {msg}]"
                    '''
                    recordIssues tools:
                        [
                        pyLint(name: 'Bandit', pattern: 'bandit.out')],
                        qualityGates: [
                            [threshold: 1, type: 'TOTAL', unstable: true], 
                            [threshold: 2, type: 'TOTAL', unstable: false]
                        ]
                }
            }
        }
        
       stage('SAM Build') {
            steps{
                echo 'Package sam application:'
                sh "bash pipelines/common-steps/build.sh"
            }
        }

        stage('SAM Deploy'){
            steps{
                echo 'Initiating Deployment'
                sh '''
                        sam deploy \\
                            --force-upload \\
                            --stack-name todo-list-aws-staging \\
                            --region us-east-1 \\
                            --resolve-s3 \\
                            --config-env staging \\
                            --no-fail-on-empty-changeset \\
                            --capabilities CAPABILITY_IAM \\
                            --no-confirm-changeset \\
                    '''
            }
        }        

        stage('Integration Tests'){
            steps{
                withPythonEnv('/usr/bin/python3.10') {
                    script {
                        def BASE_URI = sh(script: "aws cloudformation describe-stacks --stack-name todo-list-aws-staging --query 'Stacks[0].Outputs[?OutputKey==`BaseUrlApi`].OutputValue' --region us-east-1 --output text", returnStdout: true).trim()
                        echo 'Initiating Integration Tests'
                        
                        // Ejecutar pytest de Python
                        sh """
                            . todo-list-aws/bin/activate
                            export BASE_URI=$BASE_URI
                            pytest -s test/integration/todoApiTest.py
                        """
                    }
                }
            }
        }
        
        stage('Promote') {
            steps {
                withPythonEnv('/usr/bin/python3.10') {
                    script {
                        git url: 'https://VIRIATO80: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@github.com/VIRIATO80/unir_todo_repo.git'
                        sh 'git add .'
                        def status = sh(script: 'git status --porcelain', returnStatus: true)
                        if (status != 0) {
                            sh 'git commit -m "Preparing release"'
                            sh 'git push -u origin develop' // Push y establecer la rama de seguimiento
                            sh 'git checkout master'  // Cambiar a la rama master
                            sh 'git merge develop' // Hacer un merge de la rama develop en la rama master
                            sh 'git push' // Subir los cambios a la rama master remota
                        } else {
                            echo 'No hay cambios para confirmar. Continuando sin hacer commit.'
                        }
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