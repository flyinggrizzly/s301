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
    describe '::publish' do
      it 'sends all existing short URLs to the RedirectPublisherService and requests a CDN invalidation for the updated or created short URL' do
        su = ShortUrl.new(slug: 'slug', redirect: 'http://www.example.com')
        publisher_service = object_double(RedirectPublisherService).as_stubbed_const
        expect(publisher_service).to receive(:publish).with(ShortUrl.all)
        expect(publisher_service).to receive(:invalidate_cdn_cache_for).with('slug')
        ShortUrl.publish(su)
      end
    end

    specify '::unpublish sends a message to the PublisherService to republish remaining short URLs' do
      su = ShortUrl.new(slug: 'sluggy-unpublish-face', redirect: 'http://www.example.com')
      publisher_service = object_double(RedirectPublisherService).as_stubbed_const
      expect(publisher_service).to receive(:publish)
      expect(publisher_service).to receive(:invalidate_cdn_cache_for)
      ShortUrl.unpublish(su)
    end
  end
end
