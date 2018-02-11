require 'redirect_publisher_service'

class ShortUrl < ApplicationRecord
  validates :slug, presence:   true,
                   uniqueness: { case_sensitive: false },
                   length:     { maximum: 255 },
                   slug:       true
  validates :redirect, presence:      true,
                       url:           true,
                       safe_redirect: true

  after_save :send_to_publisher

  def self.publish(short_url)
    publication_type = short_url.created_at == short_url.updated_at ? :new : :changed
    RedirectPublisherService.publish({ slug: short_url.slug, redirect: short_url.redirect }, publication_type)
  end

  private

  def send_to_publisher
    itself
    ShortUrl.publish(itself)
  end
end
