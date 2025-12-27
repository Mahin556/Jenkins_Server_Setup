output "jenkins_ip" {
  value = aws_instance.jenkins_server.public_ip
}

output "sonar_ip" {
  value = aws_instance.sonar_server.public_ip
}