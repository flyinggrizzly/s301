module RedirectPublisherService
  # Provides methods for interacting with AWS S3 and Cloudfront
  class AwsPublisher
    require 'aws-sdk-cloudfront'
    require 'aws-sdk-s3'

    ONE_YEAR_IN_SECONDS = 31536000

    def initialize(client_params = nil)
      @bucket        = ENV['AWS_S3_BUCKET_NAME']
      @distro_id     = ENV['AWS_CLOUDFRONT_DISTRO_ID'] || nil
      @client_params = client_params
      @s3            = s3_client
      @cloudfront    = cloudfront_client unless @distro_id.nil?
    end

    def self.new_with_stubbed_responses
      new(stub_responses: true)
    end

    def publish(short_url_data)
      validate short_url_data
      put_s3_object_for short_url_data
      create_cloudfront_invalidation_for short_url_data[:slug]
    end

    def unpublish(slug)
      delete_s3_object_for slug
      create_cloudfront_invalidation_for slug
    end

    def create_cloudfront_invalidation_for(slug)
      return unless @distro_id
      path = object_path(slug)
      txn_reference = "#{slug}-#{Time.now.iso8601}"
      @cloudfront.create_invalidation(distribution_id:    @distro_id,
                                      invalidation_batch: { paths:            { quantity: 1, items: [path] },
                                                            caller_reference: txn_reference })
    end

    def cloudfront_invalidate_all
      create_cloudfront_invalidation_for '*'
    end

    private

    def put_s3_object_for(short_url_data)
      tries ||= 3
      @s3.put_object(bucket:                    @bucket,
                     key:                       short_url_data[:slug],
                     cache_control:             s3_object_cache_control_headers,
                     website_redirect_location: short_url_data[:redirect])
    rescue Aws::S3::Errors
      retry unless (tries -= 1).zero?
    end

    def delete_s3_object_for(key)
      tries ||= 3
      @s3.delete_object(bucket: @bucket,
                        key:    key)
    rescue Aws::S3::Errors
      retry unless (tries -= 1).zero?
    end

    def validate(params)
      msg = 'requires a Hash with :slug and :redirect as parameters'
      raise(ArgumentError, msg) unless params.class.eql?(Hash) && params.keys.sort.eql?(%i[redirect slug])
    end

    def object_path(slug)
      "/#{slug}"
    end

    def s3_object_cache_control_headers
      time_a_browser_should_cache = 'max-age=0'
      time_cloudfront_should_cache = "s-maxage=#{ONE_YEAR_IN_SECONDS}"

      "#{time_a_browser_should_cache} #{time_cloudfront_should_cache}"
    end

    def s3_client
      Aws::S3::Client.new(aws_client_params)
    end

    def cloudfront_client
      Aws::CloudFront::Client.new(aws_client_params)
    end

    def aws_client_params
      # Don't merge the hashes because tests shouldn't require credentials
      @client_params || { region:            ENV['AWS_REGION'] || 'us-east-1',
                          access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
                          secret_access_key: ENV['AWS_SECRET_ACCES_KEY'] }
    end
  end
end
