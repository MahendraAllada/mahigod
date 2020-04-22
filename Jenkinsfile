pipeline {
    agent {
        node {
            label 'master'
        }
    }
    options {
    preserveStashes() 
    }
    stages {
        stage('terraform clone') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '2fb7dff5-dcb5-4e2f-94d0-90ef7ecc49a6', url: 'https://github.com/MahendraAllada/mahigod.git']]])
            }
        }
        stage('Parameters'){
            steps {
                sh label: '', script: ''' sed -i \"s/user/$access_key/g\" /var/lib/jenkins/workspace/django/variables.tf
                 sed -i \"s/password/$secret_key/g\" /var/lib/jenkins/workspace/django/variables.tf
               sed -i \"s/t2.micro/$instance_type/g\" /var/lib/jenkins/workspace/django/variables.tf
sed -i \"s/10/$instance_size/g\" /var/lib/jenkins/workspace/django/ec2.tf
sed -i \"s/ap-south-1/$instance_region/g\" /var/lib/jenkins/workspace/django/variables.tf
sed -i \"s/ap-south-1a/$availability_zone/g\" /var/lib/jenkins/workspace/django/variables.tf
sed -i \"s/alladamumbai/$key/g\" /var/lib/jenkins/workspace/django/variables.tf
sed -i \"s/ami-0470e33cd681b2476/$Image/g\" /var/lib/jenkins/workspace/django/variables.tf
'''
                  }
            }
            
        stage('terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('terraform plan') {
            steps {
                sh 'terraform plan'
            }
        }
        stage('terraform apply') {
            steps {
                sh 'terraform apply -auto-approve'
                sleep 150
            }
        }
		stage("git checkout") {
	     steps {
		    checkout([$class: 'GitSCM', branches: [[name: '*/branchPy']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'djangocodebase']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '2fb7dff5-dcb5-4e2f-94d0-90ef7ecc49a6', url: 'https://github.com/MahendraAllada/mahigod.git']]])
           }
        }
		
        stage('SonarQube analysis') {
	     steps {
	       script {
           scannerHome = tool 'sonarqube';
           withSonarQubeEnv('sonarqube') {
		   sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=zippyops:django -Dsonar.projectName=django -Dsonar.projectVersion=1.0 -Dsonar.projectBaseDir=${WORKSPACE}/djangocodebase -Dsonar.sources=${WORKSPACE}/djangocodebase"
            }
	      }
		}
	    }
        stage("Sonarqube Quality Gate") {
	     steps {
	      script { 
            sleep(60)
            qg = waitForQualityGate() 
		    }
           }
        }
	    stage("Dependency Check") {
		 steps {
	      script {  
			dependencycheck additionalArguments: '', odcInstallation: 'Dependency'
			dependencyCheckPublisher pattern: ''
        }
        archiveArtifacts allowEmptyArchive: true, artifacts: '**/dependency-check-report.xml', onlyIfSuccessful: true
        }
        } 
	    stage('Application Deployment') {
          steps {
                sh label: '', script: '''pubIP=$(<publicip)
                echo "$pubIP"
                ssh -tt -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$pubIP /bin/bash << EOF
                git clone -b branchPy https://github.com/MahendraAllada/mahigod.git
                cd Godsontf/
                chmod 755 manage.py
                python manage.py migrate
                nohup ./manage.py runserver 0.0.0.0:8000 &
                sleep 60
                exit
                EOF
                '''
            }
        }
	    stage('VAPT') {
            steps {
                 sh label: '', script: '''pubIP=$(<publicip)
                 echo "$pubIP"
                 ssh -tt root@192.168.5.14 << SSH_EOF
                 echo "open vas server"
                 python code16.py $pubIP:8000
                 exit
                 SSH_EOF 
                 '''
            }
        }
        stage('OWASP'){
            steps {
                   sh label: '', script: '''pubIP=$(<publicip)
                   echo "$pubIP"
                   touch Django_Dev_ZAP_VULNERABILITY_REPORT_${BUILD_ID}.html
                   sudo docker run --rm -v ${WORKSPACE}/out:/zap/wrk/:rw -t docker.io/owasp/zap2docker-stable zap-baseline.py -t http://$pubIP:8000 -m 15 -d -r Django_Dev_ZAP_VULNERABILITY_REPORT_${BUILD_ID}.html -x Django_Dev_ZAP_VULNERABILITY_REPORT_${BUILD_ID}.xml || true
                   '''
                   archiveArtifacts artifacts: '**/Django_Dev_ZAP_VULNERABILITY_REPORT_${BUILD_ID}.html'
		    }
        } 
        stage('linkChecker'){
            steps {
                   sh label: '', script: '''pubIP=$(<publicip)
                   echo "$pubIP"
                   date
                   sudo docker run --rm --network=host ktbartholomew/link-checker --concurrency 30 --threshold 0.05 http://$pubIP:8000 > $WORKSPACE/brokenlink_${BUILD_ID}.html || true
                   date
                   '''
                   archiveArtifacts artifacts: '**/brokenlink_${BUILD_ID}.html'
                   }
        }
        stage('SpeedTest') {
	      steps {
                   sh label: '', script: '''pubIP=$(<publicip)
                   echo "$pubIP"
		           cp -r /var/lib/jenkins/speedtest/budget.json  ${WORKSPACE}
                   sudo docker run --rm -v ${WORKSPACE}:/sitespeed.io sitespeedio/sitespeed.io http://$pubIP:8000 --outputFolder junitoutput --budget.configPath budget.json --budget.output junit -b chrome -n 3  || true
		  '''
		  }
	    }
        stage('Deployed') {
            steps {
                 sh label: '', script: '''rm -rf publicip
                 echo "Deployed"
                 '''
            }
        }
    }
}
