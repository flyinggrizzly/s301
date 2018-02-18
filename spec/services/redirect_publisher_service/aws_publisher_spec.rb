require 'rails_helper'

RSpec.describe RedirectPublisherService::AwsPublisher do

  before(:each, stub_aws_connection: true) do
    stub_s3_client
    stub_cloudfront_client
  end

  describe 'public interface' do
    before(:each, stub_s3_client: true) do
      stub_s3_client
    end

    before(:each, stub_cloudfront_client: true) do
      stub_cloudfront_client
    end

    it 'responds to #publish', :stub_s3_client do
      aws_publisher = RedirectPublisherService::AwsPublisher.new
      expect(aws_publisher).to respond_to :publish
    end

    it 'responds to #unpublish', :stub_s3_client do
      aws_publisher = RedirectPublisherService::AwsPublisher.new
      expect(aws_publisher).to respond_to :unpublish
    end

    it 'responds to #cloudfront_invalidate', :stub_cloudfront_client do
      aws_publisher = RedirectPublisherService::AwsPublisher.new
      expect(aws_publisher).to respond_to :cloudfront_invalidate
    end

    it 'responds to #cloudfront_invalidate_all', :stub_cloudfront_client do
      aws_publisher = RedirectPublisherService::AwsPublisher.new
      expect(aws_publisher).to respond_to :cloudfront_invalidate_all
    end
  end

  describe '#publish' do
    it 'requires as a parameter a hash of short URL params [:slug, :redirect]', :stub_aws_connection, :aggregate_failures do
      aws_publisher = RedirectPublisherService::AwsPublisher.new

      expect {
        aws_publisher.publish({}, :new)
      }.to raise_error(ArgumentError,
                       'requires a Hash with :slug and :redirect as parameters')

      expect(aws_publisher).to receive(:publish).with({ slug: 'foo', redirect: 'http://www.example.com' }, :new)
      aws_publisher.publish({ slug: 'foo', redirect: 'http://www.example.com' }, :new)
    end

    it 'requires a publication_type parameter', :stub_aws_connection, :aggregate_failures do
      aws_publisher = RedirectPublisherService::AwsPublisher.new

      short_url_hash = { slug: 'foo', redirect: 'http://www.example.com' }
      expect {
        aws_publisher.publish(short_url_hash, :foo)
      }.to raise_error(ArgumentError,
                       'publication_type must be :new or :changed')

      expect(aws_publisher).to receive(:publish).with(short_url_hash, :new)
      aws_publisher.publish(short_url_hash, :new)

      expect(aws_publisher).to receive(:publish).with(short_url_hash, :changed)
      aws_publisher.publish(short_url_hash, :changed)
    end

    it 'sends a put_object request to S3 for new short URLs', :stub_aws_connection do
      s3 = instance_double(Aws::S3::Client)
      expect(s3).to receive(:put_object)
      aws_publisher = RedirectPublisherService::AwsPublisher.new

      # Inject spy
      aws_publisher.instance_variable_set(:@s3, s3)

      aws_publisher.publish({ slug: 'foo', redirect: 'http://www.example.com' }, :new)
    end

    it 'sends a copy_object request to S3 for updated short URLs', :stub_aws_connection do
      s3 = instance_double(Aws::S3::Client)
      expect(s3).to receive(:copy_object)
      aws_publisher = RedirectPublisherService::AwsPublisher.new

      # Inject spy
      aws_publisher.instance_variable_set(:@s3, s3)

      aws_publisher.publish({ slug: 'foo', redirect: 'http://www.example.com' }, :changed)
    end

    it 'invalidates the cloudfront cache for the slug', :stub_aws_connection do
      aws_publisher = RedirectPublisherService::AwsPublisher.new

      expect_any_instance_of(RedirectPublisherService::AwsPublisher).to receive(:cloudfront_invalidate)

      aws_publisher.publish({ slug: 'foo', redirect: 'http://www.example.com' }, :new)
    end
  end

  describe '#unpublish' do
    it 'sends a destroy_object request to S3', :stub_aws_connection do
      s3 = instance_double(Aws::S3::Client)
      expect(s3).to receive(:delete_object).and_return(true)
      aws_publisher = RedirectPublisherService::AwsPublisher.new

      # Inject spy
      aws_publisher.instance_variable_set(:@s3, s3)

      aws_publisher.unpublish(slug: 'foo', redirect: 'http://www.example.com')
    end

    it 'invalidates the cloudfront cache for the slug', :stub_aws_connection do
      aws_publisher = RedirectPublisherService::AwsPublisher.new

      expect_any_instance_of(RedirectPublisherService::AwsPublisher).to receive(:cloudfront_invalidate)

      aws_publisher.unpublish(slug: 'foo', redirect: 'http://www.example.com')
    end
  end

  describe '#cloudfront_invalidate' do
    it 'sends a create_invalidation request to Cloudfront', :stub_aws_connection do
      cloudfront = instance_double(Aws::CloudFront::Client)
      expect(cloudfront).to receive(:create_invalidation)
      aws_publisher = RedirectPublisherService::AwsPublisher.new

      aws_publisher.instance_variable_set(:@cloudfront, cloudfront)
      aws_publisher.cloudfront_invalidate('foo')
    end
  end

  describe '#cloudfront_invalidate_all' do
    it 'calls #cloudfront_invalidate with a wildcard parameter', :stub_aws_connection do
      expect_any_instance_of(RedirectPublisherService::AwsPublisher).to receive(:cloudfront_invalidate).with('*')
      aws_publisher = RedirectPublisherService::AwsPublisher.new
      aws_publisher.cloudfront_invalidate_all
    end
  end

  private

  def stub_s3_client
    s3_client = instance_double(Aws::S3::Client)
    s3_client_class = class_double(Aws::S3::Client)
    allow(s3_client_class).to receive(:new)
      .and_return(s3_client)
  end

  def stub_cloudfront_client
    cloudfront_client = instance_double(Aws::CloudFront::Client)
    cloudfront_client_class = class_double(Aws::CloudFront::Client)
    allow(cloudfront_client_class).to receive(:new)
      .and_return(cloudfront_client)
  end
end
