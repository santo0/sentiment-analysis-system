wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/ubuntu/miniconda3
source /home/ubuntu/miniconda3/bin/activate
pip install -r model/requirements.txt
rm Miniconda3-latest-Linux-x86_64.sh