require 'rails_helper'

RSpec.describe RedirectPublisherService do
  describe 'public interface' do
    it 'responds to ::publish' do
      expect(RedirectPublisherService).to respond_to(:publish)
    end

    it 'responds to ::unpublish' do
      expect(RedirectPublisherService).to respond_to(:unpublish)
    end
  end

  it 'includes an AWS publisher' do
  end

  describe '::publish' do
    it 'requires a hash parameter with slug and redirect values', :aggregate_failures do
      aws_publisher = instance_double(RedirectPublisherService::AwsPublisher)
      expect(aws_publisher).to receive(:publish)
        .with({ slug: 'foo', redirect: 'http://www.example.com' }, :new)

      aws_pub_class = class_double(RedirectPublisherService::AwsPublisher).as_stubbed_const
      allow(aws_pub_class).to receive(:new).and_return(aws_publisher)

      error_message = 'short URLs cannot be published without both slug and redirect'

      expect {
        RedirectPublisherService.publish({ slug: nil, redirect: 'http:www.example.com' }, :new)
      }.to raise_error error_message
      expect {
        RedirectPublisherService.publish({ slug: 'foo', redirect: nil }, :new)
      }.to raise_error error_message
      RedirectPublisherService.publish({ slug: 'foo', redirect: 'http://www.example.com' }, :new)
    end

    it 'requires a publication_type parameter with either :new or :changed' do
      short_url = { slug: 'foo', redirect: 'http://www.example.com' }

      aws_publisher = instance_double(RedirectPublisherService::AwsPublisher)
      expect(aws_publisher).to receive(:publish)
        .with(short_url, :new)
      expect(aws_publisher).to receive(:publish)
        .with(short_url, :changed)

      aws_pub_class = class_double(RedirectPublisherService::AwsPublisher).as_stubbed_const
      allow(aws_pub_class).to receive(:new).and_return(aws_publisher) 


      RedirectPublisherService.publish(short_url, :new)
      RedirectPublisherService.publish(short_url, :changed)
      expect{
        RedirectPublisherService.publish(short_url, :bad)
      }.to raise_error '`publication_type` must be `:new` or `:changed`'
    end

    it 'sends a message to the selected publisher to publish a short URL' do
      pending "implicitly tested by other ::publish specs, don't implement until there are other publishers"
      expect(true).to eq(false)
    end
  end

  describe '::unpublish' do
    it 'requires a hash parameter with slug and redirect values', :aggregate_failures do
      aws_publisher = instance_double(RedirectPublisherService::AwsPublisher)
      expect(aws_publisher).to receive(:unpublish)
        .with(slug: 'foo', redirect: 'http://www.example.com')

      aws_pub_class = class_double(RedirectPublisherService::AwsPublisher).as_stubbed_const
      allow(aws_pub_class).to receive(:new).and_return(aws_publisher)

      error_message = 'short URLs cannot be unpublished without both slug and redirect'

      expect {
        RedirectPublisherService.unpublish(slug: nil, redirect: 'http://www.example.com')
      }.to raise_error error_message
      expect {
        RedirectPublisherService.unpublish(slug: 'foo', redirect: nil)
      }.to raise_error error_message
      RedirectPublisherService.unpublish(slug: 'foo', redirect: 'http://www.example.com')
    end

    it 'sends a message to the selected publisher to unpublish a short URL' do
      pending "implicitly tested by other ::publish specs, don't implement until there are other publishers"
      expect(true).to eq(false)
    end
  end
end
