output "instance_publicip" {
    value = "http://${aws_instance.Multi_Env_instance.public_ip}:8080"
}