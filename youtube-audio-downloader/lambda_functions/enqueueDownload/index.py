import boto3
import os
from urllib.parse import urlparse
import time


dynamodb = boto3.client("dynamodb")
sqs = boto3.client("sqs")

queue_url = os.environ.get("SQS_QUEUE_URL")
download_status_table_name = os.environ.get("DYNAMODB_DOWNLOAD_STATUS_TABLE_NAME")
user_history_table_name = os.environ.get("DYNAMODB_USER_HISTORY_TABLE_NAME")


def lambda_handler(event, context):
    print("event:", event)

    url = get_url_from_event(event)
    if url is None:
        raise "no url provided"

    video_id = get_video_id_from_url(url)

    if dynamodb_get_video_status(video_id) == "enqueued":
        return f"Video {video_id} is already enqueued. Skipping."

    user_id = event["identity"]["username"]
    dynamodb_add_video_to_user_history(user_id, video_id)

    dynamodb_enqueue_video(video_id)

    sqs_add_url(url)

    print("OK")
    return f"Enqueued video id {video_id}"


def get_url_from_event(event):
    return event.get("variables").get("url") or event.get("arguments").get("input").get(
        "url"
    )


def get_video_id_from_url(url):
    # url formats
    # https://www.youtube.com/watch?v=oZtTut7QsZ8&ab_channel=JamieBarton
    # https://youtu.be/oZtTut7QsZ8?si=db-zG8xkPHUOfyzG
    parse_result = urlparse(url)

    if parse_result.hostname == "www.youtube.com":
        query_components = parse_result.query.split("&")
        query_dict = {}
        for query_component in query_components:
            key, value = query_component.split("=")
            query_dict[key] = value

        return query_dict["v"]

    elif parse_result.hostname == "youtu.be":
        path = parse_result.path.replace("/", "")
        return path
    else:
        return None


def dynamodb_enqueue_video(video_id):
    dynamodb.put_item(
        TableName=download_status_table_name,
        Item={
            "video_id": {"S": video_id},
            "status": {"S": "enqueued"},
        },
    )


def dynamodb_get_video_status(video_id):
    item = dynamodb.get_item(
        TableName=download_status_table_name, Key={"video_id": {"S": video_id}}
    )
    return item.get("Item", {}).get("status", {}).get("S")


def dynamodb_add_video_to_user_history(user_id, video_id):
    current_timestamp = int(time.time())

    dynamodb.put_item(
        TableName=user_history_table_name,
        Item={
            "user_id": {"S": user_id},
            "video_id": {"S": video_id},
            "timestamp": {"N": f"{current_timestamp}"},
        },
    )


def sqs_add_url(url):
    sqs_response = sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=(url),
    )

    print("sqs_response:", sqs_response)
