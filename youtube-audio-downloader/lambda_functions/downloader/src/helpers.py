from urllib.parse import urlparse


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
