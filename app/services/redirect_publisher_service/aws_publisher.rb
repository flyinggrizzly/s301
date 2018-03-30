module RedirectPublisherService
  # Provides methods for interacting with AWS S3 and Cloudfront
  class AwsPublisher
    require 'aws-sdk-cloudfront'
    require 'aws-sdk-s3'

    def initialize(client_params = nil)
      @bucket        = ENV['AWS_S3_BUCKET_NAME']
      @distro_id     = ENV['AWS_CLOUDFRONT_DISTRO_ID'] || nil
      @client_params = client_params
      @s3            = s3_client
      @cloudfront    = cloudfront_client unless @distro_id.nil?
    end

    def publish(short_url_data, publication_type)
      validate_publish_params(short_url_data)
      raise(ArgumentError, 'publication_type must be :new or :changed') unless %i[new changed].include? publication_type
      @short_url = short_url_data

      case publication_type
      when :new
        s3_create_short_url
      when :changed
        s3_update_short_url
      end
      # Always invalidating the CF cache means that even short URLs that had a failed delete
      # action and have since been recreated will be up to date
      cloudfront_invalidate short_url[:slug]
    end

    def unpublish(short_url_data)
      @short_url = short_url_data

      s3_delete_short_url
      cloudfront_invalidate(short_url[:slug])
    end

    def cloudfront_invalidate(slug)
      return unless @distro_id
      path = object_path(slug)
      txn_reference = "#{slug}-#{Time.now.iso8601}"
      @cloudfront.create_invalidation(distribution_id:    @distro_id,
                                      invalidation_batch: { paths:            { quantity: 1, items: [path] },
                                                            caller_reference: txn_reference })
    end

    def cloudfront_invalidate_all
      cloudfront_invalidate('*')
    end

    private

    def validate_publish_params(params)
      msg = 'requires a Hash with :slug and :redirect as parameters'
      raise(ArgumentError, msg) unless params.class.eql?(Hash) && params.keys.sort.eql?(%i[redirect slug])
    end

    def short_url
      { slug:     @short_url[:slug],
        redirect: @short_url[:redirect] }
    end

    def s3_create_short_url
      tries ||= 3
      @s3.put_object(bucket:                    @bucket,
                     key:                       short_url[:slug],
                     cache_control:             'max-age=0, no-cache, no-store, must-revalidate',
                     website_redirect_location: short_url[:redirect])
    rescue Aws::S3::Errors
      retry unless (tries -= 1).zero?
    end

    def s3_update_short_url
      tries ||= 3
      @s3.copy_object(bucket:                    @bucket,
                      copy_source:               "#{@bucket}/#{short_url[:slug]}",
                      key:                       short_url[:slug],
                      cache_control:             'max-age=0, no-cache, no-store, must-revalidate',
                      website_redirect_location: short_url[:redirect],
                      metadata_directive:        'REPLACE')
    rescue Aws::S3::Errors
      (tries -= 1).zero? ? s3_create_short_url : retry
    end

    def s3_delete_short_url
      tries ||= 3
      @s3.delete_object(bucket: @bucket,
                        key:    short_url[:slug])
    rescue Aws::S3::Errors
      retry unless (tries -= 1).zero?
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
      @client_params || { region:            ENV['AWS_REGION'] || 'us-east-1',
                          access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
                          secret_access_key: ENV['AWS_SECRET_ACCES_KEY'] }
    end
  end
end
