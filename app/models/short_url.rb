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
    slug, redirect = validate_and_assign_publication_args_for short_url
    RedirectPublisherService.publish({ slug: slug, redirect: redirect }, :new)
  end

  def self.republish(short_url)
    slug, redirect = validate_and_assign_publication_args_for short_url
    RedirectPublisherService.publish({ slug: slug, redirect: redirect }, :changed)
  end

  def self.unpublish(short_url)
    slug, redirect = validate_and_assign_publication_args_for short_url
    RedirectPublisherService.unpublish(slug: slug, redirect: redirect)
  end

  private_class_method def self.validate_and_assign_publication_args_for(short_url)
    # Case behaves strangely with .class--call directly against object
    # see https://stackoverflow.com/questions/948135/how-to-write-a-switch-statement-in-ruby#answer-5694333
    case short_url
    when ShortUrl
      [short_url.slug, short_url.redirect]
    when Hash
      raise ArgumentError, 'hash keys must be :slug and :redirect' unless short_url.keys.sort.eql? %i[redirect slug]
      [short_url[:slug], short_url[:redirect]]
    else
      raise ArgumentError, 'Expected a Hash or ShortUrl object'
    end
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
