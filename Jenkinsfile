#!/usr/bin/env groovy
pipeline {
    agent any

  //declare aws parameters
  environment {
    AWS_REGION         = 'us-east-1'
    AWS_DEFAULT_REGION = 'us-east-1'
    AWS_DEFAULT_OUTPUT = 'text'

  }

  options {
    buildDiscarder(logRotator(daysToKeepStr: '7'))
  }

  stages {


    stage('docker build push') {
      steps{
        withCredentials([
          [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-dev', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']
        ]){
              script {
                sh 'chmod +x ecr.sh'
                sh './ecr.sh'
              }
            }
          }
        }
      }
    }
