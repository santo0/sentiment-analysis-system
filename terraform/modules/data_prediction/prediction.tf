provider "aws" {
  region = "us-east-1"
}

data "aws_iam_instance_profile" "instance_profile" {
  name = "LabInstanceProfile"
}

# Define the security group
resource "aws_security_group" "prediction_sg" {
  name        = "ccbda-prediction-sg"
  description = "Security group for prediction instance"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ccbda-prediction-sg"
  }
}

resource "aws_instance" "prediction" {
  ami           = "ami-04b70fa74e45c3917"  # Update this to an Ubuntu AMI ID for your region
  instance_type = "m5.large"
  iam_instance_profile = data.aws_iam_instance_profile.instance_profile.name
  key_name = "vockey"
  security_groups = [aws_security_group.prediction_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt install unzip
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
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
