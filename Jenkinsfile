def reg = [credentialsId: 'hebertsonmx', url: 'https://index.docker.io/v1/']
pipeline {
  agent none
    
  stages {
        stage( 'build and push stage image' ) {

          steps {
            withDockerRegistry(reg) {
              sh """
                docker image build --tag hebertsonm/ruby:latest . && \
                docker image push hebertsonm/ruby:latest
              """
            }
          }
        }
  }
}
