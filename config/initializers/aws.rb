require "aws-sdk-s3"

# Only configure if both keys are set (in EB production environment)
if ENV["AWS_ACCESS_KEY_ID"].present? && ENV["AWS_SECRET_ACCESS_KEY"].present?
  Aws.config.update(
    credentials: Aws::Credentials.new(
      ENV["AWS_ACCESS_KEY_ID"],
      ENV["AWS_SECRET_ACCESS_KEY"]
    ),
    region:      ENV.fetch("AWS_REGION", "ap-northeast-1")
  )
end
