module RedirectPublisherService
  # Provides methods for interacting with AWS S3 and Cloudfront
  class AwsPublisher
    require 'aws-sdk-cloudfront'
    require 'aws-sdk-s3'

    def initialize
      @s3         = s3_client
      @cloudfront = cloudfront_client
      @bucket     = ENV['AWS_S3_BUCKET_NAME']
      @distro_id  = ENV['AWS_CLOUDFRONT_DISTRO_ID'] || nil
    end

    def publish(short_url, publication_type)
      case publication_type
      when :new
        s3_create short_url
      when :changed
        s3_update short_url
      end
    end

    private

    def s3_create(short_url)
      @s3.put_object(
        bucket:                    @bucket,
        key:                       short_url[:slug],
        website_redirect_location: short_url[:redirect]
      )
    end

    def s3_update(short_url)
      slug = short_url[:slug]
      @s3.copy_object(bucket:             @bucket,
                      copy_source:        "#{@bucket}/#{slug}",
                      key:                slug,
                      website_redirect_location: short_url[:redirect],
                      metadata_directive: 'REPLACE')
      cloudfront_invalidate(slug) unless @distro_id.nil?
    end

    def cloudfront_invalidate(slug)
      path = object_path(slug)
      txn_reference = "#{slug}-#{Time.now.iso8601}"
      @cloudfront.create_invalidation(distribution_id:    @distro_id,
                                      invalidation_batch: { paths:            { quantity: 1, items: [path] },
                                                            caller_reference: txn_reference })
    end

    def object_path(slug)
      "/#{slug}"
    end

    def s3_client
      Aws::S3::Client.new(aws_client_params)
    end

    def cloudfront_client
      Aws::CloudFront::Client.new(aws_client_params)
    end

    def aws_client_params
      { region:            ENV['AWS_REGION'] || 'us-east-1',
        access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCES_KEY'] }
    end
  end
end
