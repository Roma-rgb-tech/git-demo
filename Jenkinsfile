pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        echo 'Hello'
      }
    }

    stage('Test') {
      steps {
        sh '''./jenkins/scripts/test.sh
'''
      }
    }

  }
}