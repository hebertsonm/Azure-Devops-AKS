node {
    checkout scm
    def customImage = docker.build("hebertsonm/ruby:latest","ruby/")
    customImage.push()
}
