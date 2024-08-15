APP_VERSION_FILE := ../../app_version.txt
APP_VERSION := $(shell cat ${APP_VERSION_FILE})

DOCKERFILE_BASE := Dockerfile-python-ffmpeg
BASE_IMAGE_NAME := python-ffmpeg

DOCKERFILE_LAMBDA := Dockerfile-lambda
LAMBDA_IMAGE_NAME := yt-dlp

ACCOUNT_ID := 827463403506
REGION := eu-west-1
ECR_REGISTRY := ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
REPO := yt-dlp-downloader
IMAGE_URI := ${ECR_REGISTRY}/${REPO}:${APP_VERSION}

docker/build-base :
	docker build -f ${DOCKERFILE_BASE} --platform linux/amd64 -t ${BASE_IMAGE_NAME}:latest .

docker/build-lambda : docker/build-base
	docker build -f ${DOCKERFILE_LAMBDA} --platform linux/amd64 -t ${LAMBDA_IMAGE_NAME}:${APP_VERSION} --build-arg baseimage=${BASE_IMAGE_NAME} .
	
docker/push : docker/build-lambda
	aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
	docker tag ${LAMBDA_IMAGE_NAME}:${APP_VERSION} ${IMAGE_URI}
	docker push ${IMAGE_URI}

docker/run :
	docker run -p 9000:8080 $(ECR_REGISTRY)/$(REPO):$(APP_VERSION)

docker/test :
	curl -XPOST 'http://localhost:9000/2015-03-31/functions/function/invocations' -d '{}'