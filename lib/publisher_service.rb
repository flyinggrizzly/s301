module PublisherService
  require 'aws-sdk-cloudfront'
  require 'aws-sdk-s3'

  def self.publish(item)
    # For AWS
    # authenticate
    # update S3 object
    # invalidate Cloudfront cache
  end

  def authenticate_with_aws
  end

  def s3_put(object)
  end

  def cloudfront_invalidate(object)
  end
end
