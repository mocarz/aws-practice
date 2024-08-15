import os
import asyncio
from urllib.parse import urlparse
from gql import Client, gql
from gql.transport.aiohttp import AIOHTTPTransport
from gql.transport.appsync_auth import AppSyncApiKeyAuthentication

url = os.environ.get("AWS_GRAPHQL_API_ENDPOINT")
api_key = os.environ.get("AWS_GRAPHQL_API_KEY")


async def appsyncExecute(queryString, variable_values):
    host = str(urlparse(url).netloc)

    auth = AppSyncApiKeyAuthentication(host=host, api_key=api_key)

    transport = AIOHTTPTransport(url=url, auth=auth)

    async with Client(
        transport=transport,
        fetch_schema_from_transport=False,
    ) as session:
        query = gql(queryString)
        result = await session.execute(
            query,
            variable_values=variable_values,
            get_execution_result=True,
            parse_result=True,
        )
        print("Appsync query result:", result)


def setDownloadStatusInProgress(video_id):
    setDownloadStatus(video_id, "in-progress", None)


def setDownloadStatusFailed(video_id):
    setDownloadStatus(video_id, "failed", None)


def setDownloadStatusFinished(video_id, filename):
    setDownloadStatus(video_id, "finished", filename)


def setDownloadStatus(video_id, status, filename):
    query = """
mutation UpdateDownloadStatus($video_id: String!, $status: String!, $filename: String) {
    updateDownloadStatus(input: { video_id: $video_id, status: $status, filename: $filename }) {
        video_id
        status
        filename
    }
}
"""
    variables = {"video_id": video_id, "status": status, "filename": filename}

    asyncio.run(appsyncExecute(query, variable_values=variables))
