@Library(['sw_jenkins', 'sw_ciinabox']) _

def buildInfo = Artifactory.newBuildInfo()

pipeline {
  parameters {
    booleanParam(name: 'PUBLISH', defaultValue: isReleaseBranch(), description: 'Publish to Artifactory')
    booleanParam(name: 'NOTIFY_FAILURE', defaultValue: isReleaseBranch(), description: 'Notify failures to Slack')
  }
  agent {
    label 'docker'
  }
  options {
    timeout(time: 30, unit: 'MINUTES')
  }
  environment {
    PROJECT_NAME = 'libMultiMarkdown'
  }
  stages {
    stage('config') {
      steps {
        script {
          env['BUILD_VER'] = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}-${env.GIT_COMMIT.substring(0,7)}"
          println "BUILD_VER: ${env.BUILD_VER}"
          projects = ["libMultiMarkdown"]
        }
      }
    }
    stage('Build') {
      steps {
        script {
          docker.withRegistry('https://smartward-docker.jfrog.io', 'artifactory-jenkins-api-key') {
            img = docker.build("libMultiMarkdown", "--pull -f Dockerfile .")
          }
          archiveArtifacts artifacts: "multimakrdown_*.deb"
        }
      }
    }
    stage('publish') {
      when { expression { params.PUBLISH } }
      parallel {
        stage('publish Artifactory') {
          steps {
            script {
              def tags = swTags()
              def patterns = [
                "multimakrdown_*.deb"
              ]
              swArtifactoryUpload(project:"libMultiMarkdown", patterns:patterns, tags:tags, buildInfo: buildInfo)
              swArtifactoryPublishBuildInfo(buildInfo: buildInfo)
            }
          }
        }
      }
    }
  }
  post {
    failure {
      script {
        if (params.NOTIFY_FAILURE) {
          slackSend (color: '#FF0000', message: "FAILED: <${env.BUILD_URL}|${env.JOB_NAME} #${env.BUILD_NUMBER}>")
        }
      }
    }
  }
}
