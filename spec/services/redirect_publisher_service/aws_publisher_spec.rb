require 'rails_helper'
require 'nokogiri/xml'
require 'redirect_publisher_service'

RSpec.describe RedirectPublisherService::AwsPublisher do

  describe 'public interface' do
    let(:aws_publisher) { described_class.new_with_stubbed_responses }

    it 'responds to #publish_redirects_for' do
      expect(aws_publisher).to respond_to :publish_redirects_for
      expect(aws_publisher.method(:publish_redirects_for)).to eq aws_publisher.method(:define_bucket_redirect_rules_for)
    end

    it 'responds to #create_cloudfront_invalidation_for' do
      expect(aws_publisher).to respond_to :create_cloudfront_invalidation_for
    end

    it 'responds to #cloudfront_invalidate_all' do
      expect(aws_publisher).to respond_to :cloudfront_invalidate_all
    end
  end

  describe '#publish_redirects_for' do
    let(:aws_publisher) { described_class.new }
    it 'sends a PUT request to configure the bucket with redirects and index and error documents' do
      WebMock.stub_request(:put, "https://#{ENV['AWS_S3_BUCKET_NAME']}.s3.amazonaws.com/?website")
      aws_publisher.publish_redirects_for([ShortUrl.new(slug: 'da-slug', redirect: 'http://www.example.com'),
                                           ShortUrl.new(slug: 'da-slug-2', redirect: 'http://www.example.com')])
      expect(WebMock).to have_requested(:put, "https://#{ENV['AWS_S3_BUCKET_NAME']}.s3.amazonaws.com/?website")
        .with { |req| req.body == bucket_config_update_request_body }
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

  def bucket_config_update_request_body
    <<~REQUEST_BODY
      <WebsiteConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
        <ErrorDocument>
          <Key>unknown-short-url</Key>
        </ErrorDocument>
        <IndexDocument>
          <Suffix>index</Suffix>
        </IndexDocument>
        <RoutingRules>
          <RoutingRule>
            <Condition>
              <KeyPrefixEquals>da-slug</KeyPrefixEquals>
            </Condition>
            <Redirect>
              <HostName>www.example.com</HostName>
              <HttpRedirectCode>307</HttpRedirectCode>
              <Protocol>http</Protocol>
              <ReplaceKeyWith></ReplaceKeyWith>
            </Redirect>
          </RoutingRule>
          <RoutingRule>
            <Condition>
              <KeyPrefixEquals>da-slug-2</KeyPrefixEquals>
            </Condition>
            <Redirect>
              <HostName>www.example.com</HostName>
              <HttpRedirectCode>307</HttpRedirectCode>
              <Protocol>http</Protocol>
              <ReplaceKeyWith></ReplaceKeyWith>
            </Redirect>
          </RoutingRule>
        </RoutingRules>
      </WebsiteConfiguration>
    REQUEST_BODY
  end
end
