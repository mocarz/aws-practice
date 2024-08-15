## About the project

The Youtube-audio-downloader is a cloud-based service designed to extract and download audio content from Youtube videos. The service accepts an URL to a Youtube video and asynchronously returns an audio URL. The entire infrastructure is built on AWS and is provisioned and managed using Terraform. 

The service offers a GraphQL API with the following capabilities:
* a mutation that initiates the audio download process
* a query that allows users to check the status of the download and retrieves the URL for the downloaded audio
* a subscription that notifies the client upon the completion of the audio download

The API is secured using Cognito User Pool service, ensuring that only authenticated users can access the service.

Utilized AWS services:
* **Cognito User Pool**: For authentication and user management
* **Appsync**: To manage the GraphQL API
* **Lambda**: for serverless execution of backend logic, written in Python
* **ECR**: for storing Lambda container images
* **SQS**: To queue downloading tasks
* **DynamoDB**: For managing and storing data
* **S3**: For storing downloaded audio files
* **Cloudfront**: For content delivery and caching

The downloader utilizes [yt-dlp](https://github.com/yt-dlp/yt-dlp) project for downloading the video and [ffmpeg](https://github.com/FFmpeg/FFmpeg) for the video to audio conversion.

## Architecture diagram

![Architecture diagram](doc/diagram-light.svg#gh-light-mode-only)
![Architecture diagram](doc/diagram-dark.svg#gh-dark-mode-only)

