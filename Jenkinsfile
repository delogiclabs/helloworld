String appName = 'helloworld'
String appVersion = '1.1.0'
String appPort = 8108

node {
	checkout scm
	
	stage('Install node modules') {
		docker.image('node:14').inside('-u 0:0') {
			sh("npm install")
			sh("sed -i \"s/app_version/${appVersion}-${BUILD_NUMBER}/g\" app.js")
			sh 'tar cvzf ${appName}-${appVersion}-"${BRANCH_NAME}"."${BUILD_NUMBER}".tar.gz node_modules/'
  	}
		archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
	}

  stage('Build & Tag Docker image(s)') {
		// withCredentials([usernamePassword(credentialsId: 'github', usernameVariable: 'username', passwordVariable: 'password')]) {	
			// withEnv(['BRANCH_NAME = sh(returnStdout: true, script: \'git rev-parse --abbrev-ref HEAD\').trim()']) {
				// sh("docker login -u ${username} -p ${password}")
				sh """
					docker build -t ${appName}:${appVersion}-${BRANCH_NAME}.${BUILD_NUMBER} -t ${appName}:${BRANCH_NAME}.latest .
					docker images|grep ${appName}
				"""
			// }
		// }
	}

}

