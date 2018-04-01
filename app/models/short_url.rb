require 'redirect_publisher_service'

class ShortUrl < ApplicationRecord
  validates :slug, presence:   true,
                   uniqueness: { case_sensitive: false },
                   length:     { maximum: 255 },
                   slug:       true
  validates :redirect, presence:      true,
                       url:           true,
                       safe_redirect: true

  after_save     :publish
  before_destroy :unpublish

  def self.publish(short_url = nil)
    RedirectPublisherService.publish(ShortUrl.all)
    slug_to_invalidate = short_url ? short_url.slug : '*'
    RedirectPublisherService.invalidate_cdn_cache_for slug_to_invalidate
  end

  def self.unpublish(short_url)
    extant_short_urls = ShortUrl.all - [short_url]
    RedirectPublisherService.publish(extant_short_urls)
    RedirectPublisherService.invalidate_cdn_cache_for short_url.slug
  end

  private

  def publish
    ShortUrl.publish(itself)
  rescue StandardError
    flash[:error] = 'Short URL could not be published'
    throw :abort
  end

  def unpublish
    ShortUrl.unpublish(itself)
  rescue StandardError
    # Do not remove short URL from database if we couldn't unpublish it. We don't want to hide problems!
    flash[:error] = 'Short URL could not be unpublished'
    throw :abort
  end
end
