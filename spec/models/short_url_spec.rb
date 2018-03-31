require 'rails_helper'

RSpec.describe ShortUrl, type: :model do

  around(:each, skip_publish_callback: true) do |ex|
    ShortUrl.skip_callback(:save, :after, :publish)
    ex.run
    ShortUrl.set_callback(:save, :after, :publish)
  end

  it 'validates the presence of a slug' do
    su = ShortUrl.new(slug: nil, redirect: 'http://www.example.com')
    expect(su).not_to be_valid
  end

  it 'validates the uniqueness of a slug', :skip_publish_callback do
    create(:short_url, slug: 'the-slug')
    su = ShortUrl.new(slug: 'the-slug', redirect: 'http://www.example.com')

    expect(su).not_to be_valid
  end

  it 'validates the length of a slug to be 255 chars or less' do
    super_long_slug = 'a' * 256
    su = ShortUrl.new(slug: super_long_slug, redirect: 'http://www.example.com')

    expect(su).not_to be_valid
  end

  it 'validates the slug cannot use strange characters' do
    %w[f&a f*a f^a f+a f$a f%a f/a f.a f~a f:a].each do |bad_slug|
      su = ShortUrl.new(slug: bad_slug, redirect: 'http://www.example.com')
      expect(su).not_to be_valid
    end
  end

  it 'validates the presence of a redirect' do
    su = ShortUrl.new(slug: 'foo', redirect: nil)
    expect(su).not_to be_valid
  end

  describe 'class methods' do
    specify '::publish sends a message to the PublisherService to publish a resource' do
      publisher_service = object_double(RedirectPublisherService).as_stubbed_const
      expect(publisher_service).to receive(:publish)
        .with(slug: 'sluggy-mc-slugface', redirect: 'http://www.example.com')

      ShortUrl.publish(slug: 'sluggy-mc-slugface', redirect: 'http://www.example.com')
    end

    specify '::unpublish sends a message to the PublisherService to unpublish a resource' do
      publisher_service = object_double(RedirectPublisherService).as_stubbed_const
      expect(publisher_service).to receive(:unpublish)
        .with('sluggy-unpublish-face')

      ShortUrl.unpublish(slug: 'sluggy-unpublish-face', redirect: 'http://www.example.com')
    end
  end
end
