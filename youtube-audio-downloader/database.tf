resource "aws_dynamodb_table" "download_status" {
  name         = "yt_dlp_download_status"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "video_id"

  attribute {
    name = "video_id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "user_history" {
  name         = "yt_dlp_user_history"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key = "video_id"
  
  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "video_id"
    type = "S"
  }
}
