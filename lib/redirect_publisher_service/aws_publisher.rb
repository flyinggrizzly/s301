module RedirectPublisherService
  # Provides methods for interacting with AWS S3 and Cloudfront
  class AwsPublisher
    require 'addressable'
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

    # Convenience constructor for creating a test object that uses the AWS SDK response stubs
    def self.new_with_stubbed_responses
      new(stub_responses: true)
    end

    def define_bucket_redirect_rules_for(short_urls)
      config = s3_bucket_site_config_with(short_urls)
      @s3.put_bucket_website(
        bucket: @bucket,
        website_configuration: config
      )
    end
    alias publish_redirects_for define_bucket_redirect_rules_for

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

    def object_path(slug)
      "/#{slug}"
    end

    def s3_bucket_site_config_with(short_urls)
      config = {
        error_document: { key: 'unknown-short-url' },
        index_document: { suffix: 'index' },
      }
      config.merge(routing_rules: generate_redirect_rules_hash_for(short_urls)) if short_urls.first
    end

    def generate_redirect_rules_hash_for(short_urls)
      short_urls.map do |short_url|
        redirect = Addressable::URI.heuristic_parse(short_url.redirect)
        { condition: { key_prefix_equals: short_url.slug },
          redirect: { host_name: redirect.host,
                      replace_key_with: redirect.path,
                      protocol: redirect.scheme,
                      http_redirect_code: '307' } }
      end
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
