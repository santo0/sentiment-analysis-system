
account_id="975050200630"
region="us-east-1"
repository="ccbda-prediction"

aws ecr get-login-password --region ${region} | sudo docker login --username AWS --password-stdin ${account_id}.dkr.ecr.${region}.amazonaws.com
sudo docker build -t ${repository} ../
sudo docker tag ${repository}:latest ${account_id}.dkr.ecr.${region}.amazonaws.com/${repository}:latest
sudo docker push ${account_id}.dkr.ecr.${region}.amazonaws.com/${repository}:latest
