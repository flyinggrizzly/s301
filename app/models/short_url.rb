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

  def self.publish(short_url)
    publication_type = short_url.created_at == short_url.updated_at ? :new : :changed
    RedirectPublisherService.publish({ slug: short_url.slug, redirect: short_url.redirect }, publication_type)
  end

  def self.unpublish(short_url)
    RedirectPublisherService.unpublish(slug: short_url.slug, redirect: short_url.redirect)
  end

  private

  def publish
    ShortUrl.publish(itself)
  end

  def unpublish
    ShortUrl.unpublish(itself)
  rescue StandardError
    # Do not remove short URL from database if we couldn't unpublish it. We don't want to hide problems!
    flash[:error] = 'Short URL could not be unpublished'
    throw :abort
  end
end
