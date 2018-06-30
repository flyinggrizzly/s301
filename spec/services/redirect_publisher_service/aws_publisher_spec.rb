require 'rails_helper'
require 'nokogiri/xml'

RSpec.describe RedirectPublisherService::AwsPublisher do

  describe 'public interface' do
    let(:aws_publisher) { described_class.new_with_stubbed_responses }
    it 'responds to #publish' do
      expect(aws_publisher).to respond_to :publish
    end

    it 'responds to #unpublish' do
      expect(aws_publisher).to respond_to :unpublish
    end

    it 'responds to #create_cloudfront_invalidation_for' do
      expect(aws_publisher).to respond_to :create_cloudfront_invalidation_for
    end

    it 'responds to #cloudfront_invalidate_all' do
      expect(aws_publisher).to respond_to :cloudfront_invalidate_all
    end
  end

  describe '#publish' do
    let(:aws_publisher) { described_class.new }
    it 'sends a put request to S3 and invalidates the CloudFront cache when provided with a slug and URL' do
      expect(aws_publisher).to receive(:create_cloudfront_invalidation_for).with('foo')
      WebMock.stub_request(:put, s3_url_for('foo'))

      send_publish_message_for(slug: 'foo', redirect: 'http://www.example.com')

      expect(WebMock).to have_requested(:put, s3_url_for('foo'))
        .with(headers: {
                'X-Amz-Website-Redirect-Location' => 'http://www.example.com',
                'Content-Type' => 'application/octet-stream',
                'Cache-Control' => 'max-age=0, no-cache, no-store, must-revalidate'
              })
    end
  end

  describe '#unpublish' do
    let(:aws_publisher) { described_class.new }
    it 'sends a delete request to S3 and invalidates the CloudFront cache' do
      expect(aws_publisher).to receive(:create_cloudfront_invalidation_for).with('foo')
      send_unpublish_message_for 'foo'
      expect(WebMock).to have_requested(:delete, s3_url_for('foo'))
    end
  end

  describe '#create_cloudfront_invalidation_for' do
    let(:aws_publisher) { described_class.new }
    it 'sends a create_invalidation request to Cloudfront' do
      WebMock.stub_request(:post, cloudfront_url)
      aws_publisher.create_cloudfront_invalidation_for 'foo'
      expect(WebMock).to have_requested(:post, cloudfront_url)
        .with { |req|
          Nokogiri::XML(req.body).at_css('InvalidationBatch Paths Items Path')
                  .text.eql?('/foo')
        }
    end
  end

  describe '#cloudfront_invalidate_all' do
    let(:aws_publisher) { described_class.new_with_stubbed_responses }
    it 'calls #cloudfront_invalidate with a wildcard parameter' do
      expect(aws_publisher).to receive(:create_cloudfront_invalidation_for).with('*')
      aws_publisher.cloudfront_invalidate_all
    end
  end

  private

  def send_publish_message_for(slug:, redirect:)
    WebMock.stub_request(:put, s3_url_for(slug))
    WebMock.stub_request(:post, cloudfront_url)
    aws_publisher.publish(slug: slug, redirect: redirect)
  end

  def send_unpublish_message_for(slug)
    WebMock.stub_request(:delete, s3_url_for(slug))
    WebMock.stub_request(:post, cloudfront_url)
    aws_publisher.unpublish(slug)
  end

  def s3_url_for(slug)
    "https://#{ENV['AWS_S3_BUCKET_NAME']}.s3.amazonaws.com/#{slug}"
  end

  def cloudfront_url
    'https://cloudfront.amazonaws.com/2017-03-25/distribution/IAMCLOUDFRONT111/invalidation'
  end
end
