S301::Application.configure do
  aws_region = ENV['AWS_REGION'] || 'us-east-1'

  # Provide a default endpoint of the S3 bucket URL, or the endpoint defined in the environment
  config.endpoint = ENV['ENDPOINT'] || "#{ENV['AWS_S3_BUCKET_NAME']}.s3-website-#{aws_region}.amazonaws.com"
end
