# create an ec2 instance with a docker image
resource "aws_instance" "ec2_instance" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "m5.large"
  key_name      = "vockey"
  vpc_security_group_ids = ["sg-05fc7c6b519073d4e"]
  tags = {
    Name = "ec2_instance"
  }
  user_data = <<-EOF
              #!/bin/bash
              wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
              bash miniconda.sh -b -p $HOME/miniconda
              $HOME/miniconda/bin/conda init
              source ~/.bashrc
              pip install -r model/requirements.txt
              EOF
}

# sudo yum update -y
# sudo yum install docker -y
# sudo service docker start
# sudo usermod -a -G docker ec2-user
# sudo docker run -d -p 80:80 ${var.docker_image}