resource "aws_ecr_repository" "this" {
  name = "yt-dlp-downloader"
  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep last 3 images",
        "selection" : {
          "tagStatus" : "any",
          "countType" : "imageCountMoreThan",
          "countNumber" : 3
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}
