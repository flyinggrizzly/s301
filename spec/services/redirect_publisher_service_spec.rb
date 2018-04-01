require 'rails_helper'
require 'redirect_publisher_service'

WebMock.disable_net_connect!(allow_local_host: true)

RSpec.describe RedirectPublisherService do
  describe 'public interface' do
    it 'responds to ::publish' do
      expect(described_class).to respond_to :publish
    end

    it 'responds to ::invalidate_cdn_cache_for' do
      expect(described_class).to respond_to :invalidate_cdn_cache_for
    end
  end

  describe '::publish' do
    let(:aws_publisher) { described_class::AwsPublisher.new_with_stubbed_responses }
    it 'sends a message to the publisher with a batch of short URLs' do
      short_urls = [ShortUrl.new(slug: 'da-slug', redirect: 'http://www.example.com'),
                    ShortUrl.new(slug: 'go-slug', redirect: 'http://www.example.com')]
      expect(aws_publisher).to receive(:publish_redirects_for).with(short_urls)
      described_class.publish(short_urls, aws_publisher)
    end
  end

  describe '::invalidate_cdn_cache_for' do
    let(:aws_publisher) { described_class::AwsPublisher.new_with_stubbed_responses }
    it 'sends a message to the publisher with a slug' do
      expect(aws_publisher).to receive(:create_cloudfront_invalidation_for).with('sluggy')
      described_class.invalidate_cdn_cache_for('sluggy', aws_publisher)
    end
  end

  it 'includes an AWS publisher' do
    expect(described_class::AwsPublisher).to be_an_instance_of(Class)
  end
end
