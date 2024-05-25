provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "prediction" {
  ami           = "ami-04b70fa74e45c3917"  # Update this to an Ubuntu AMI ID for your region
  instance_type = "m5.large"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              $(aws ecr get-login-password --region ${var.region} | sudo docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com)
              sudo docker run -d -p 80:80 ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.repository}:latest
              EOF

  tags = {
    Name = "ccbda-prediction-instance"
  }
}

output "instance_ip" {
  value = aws_instance.prediction.public_ip
}
