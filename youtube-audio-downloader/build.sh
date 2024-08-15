#!/bin/bash

cd repository
terraform init
terraform validate
terraform apply -auto-approve
cd ..

cd lambda_functions/downloader
pip install yt-dlp -U
pip freeze | grep -v asyncio > requirements.txt

make docker/push
cd ../..

terraform init
terraform validate
terraform apply -auto-approve