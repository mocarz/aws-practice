import time
from yt_dlp import YoutubeDL
import json
import boto3
import os
import sys
import appsync_helpers
import helpers

outputBucketName = os.environ["BUCKET_NAME"]
url = os.environ.get("AWS_GRAPHQL_API_ENDPOINT")
api_key = os.environ.get("AWS_GRAPHQL_API_KEY")

s3 = boto3.client("s3")


class YoutubeDownloader:
    def __init__(self):
        self.filename = None
        self.download_directory = "/tmp/"

        self.ydl_opts = {
            "format": "m4a/bestaudio/best",
            "paths": {"home": self.download_directory, "temp": self.download_directory},
            "cachedir": False,
            "progress_hooks": [self.progress_hook],
        }

    def download(self, url):
        with YoutubeDL(self.ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            video_id = self.get_video_id_from_info(info)
            print("set download status to 'in-progress'")
            appsync_helpers.setDownloadStatusInProgress(video_id)
            print("done set download status to 'in-progress'")
            ydl.download(url)

    def progress_hook(self, d):
        global filename
        infoJson = YoutubeDL.sanitize_info(d)
        if d["status"] == "downloading":

            total_bytes = infoJson["total_bytes"]
            downloaded_bytes = infoJson["downloaded_bytes"]

            print(f"Downloaded % {downloaded_bytes/total_bytes*100}\n")

        if d["status"] == "finished":
            print("Done downloading!")

            filepath = infoJson["filename"]
            filename = os.path.basename(filepath)
            video_id = infoJson["info_dict"]["id"]

            self.upload_file_to_s3(filepath)

            appsync_helpers.setDownloadStatusFinished(video_id, filename)

    def upload_file_to_s3(self, filepath):
        print("uploading to s3")

        key = os.path.basename(filepath)

        try:
            s3.upload_file(filepath, outputBucketName, key)
            print("done uploading to s3")
        except Exception as ex:
            print("error uploading to s3: ", ex)

    def get_video_id_from_info(self, info):
        infoJson = YoutubeDL.sanitize_info(info)
        return infoJson["id"]


def validate_environment_variables():
    if url is None or api_key is None or outputBucketName is None:
        print("Missing environment variables")
        sys.exit()


def lambda_handler(event, context):
    print("event:", event)
    validate_environment_variables()

    # todo: handle more records
    url = event["Records"][0]["body"]
    if url is None:
        raise "no url provided"

    downloader = YoutubeDownloader()

    try:
        downloader.download(url)

        # video_id = helpers.get_video_id_from_url(url)
        # appsync_helpers.setDownloadStatusInProgress(video_id)

        # time.sleep(5)

        # appsync_helpers.setDownloadStatusFinished(video_id, "mock.m4a")

        print("OK")

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"status": "downloaded"}),
        }

    except Exception as ex:
        video_id = helpers.get_video_id_from_url(url)
        appsync_helpers.setDownloadStatusFailed(video_id)
        print("FAILURE")

        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(str(ex)),
        }
