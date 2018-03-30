require 'rails_helper'
require 'nokogiri/xml'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.describe RedirectPublisherService::AwsPublisher do

  describe 'public interface' do
    let(:aws_publisher) { described_class.new_with_stubbed_responses }
    it 'responds to #publish' do
      expect(aws_publisher).to respond_to :publish
    end

    it 'responds to #unpublish' do
      expect(aws_publisher).to respond_to :unpublish
    end

    it 'responds to #cloudfront_invalidate' do
      expect(aws_publisher).to respond_to :create_cloudfront_invalidation_for
    end

    it 'responds to #cloudfront_invalidate_all' do
      expect(aws_publisher).to respond_to :cloudfront_invalidate_all
    end
  end

  describe '#publish' do
    let(:aws_publisher) { described_class.new }
    it 'sends a put_object request to S3 when provided with a slug and URL' do
      send_publish_message_for(slug: 'foo', redirect: 'http://www.example.com')
      expect(WebMock).to have_requested(:put, s3_url_for('foo'))
        .with(headers: {
                'X-Amz-Website-Redirect-Location' => 'http://www.example.com'
              })
    end

    it 'invalidates the cloudfront cache for the slug' do
      send_publish_message_for(slug: 'foo', redirect: 'http://www.example.com')
      expect(WebMock).to have_requested(:post, cloudfront_url)
        .with { |req|
          Nokogiri::XML(req.body).at_css('InvalidationBatch Paths Items Path')
                  .text.eql?('/foo')
        }
    end
  end

  describe '#unpublish' do
    it 'sends a destroy_object request to S3'
    it 'invalidates the cloudfront cache for the slug'
  end

  describe '#cloudfront_invalidate' do
    it 'sends a create_invalidation request to Cloudfront'
  end

  describe '#cloudfront_invalidate_all' do
    it 'calls #cloudfront_invalidate with a wildcard parameter'
  end

  private

  def send_publish_message_for(slug:, redirect:)
    WebMock.stub_request(:put, s3_url_for(slug))
    WebMock.stub_request(:post, cloudfront_url)
    aws_publisher.publish(slug: slug, redirect: redirect)
  end

  def s3_url_for(slug)
    "https://s301-development.s3.amazonaws.com/#{slug}"
  end

  def cloudfront_url
    'https://cloudfront.amazonaws.com/2017-03-25/distribution/E1NK243MISMUEF/invalidation'
  end
end
