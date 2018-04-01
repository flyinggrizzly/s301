require 'redirect_publisher_service/aws_publisher'

# Provides methods for publishing short URLs to a static host
module RedirectPublisherService
  # Accepts a hash { slug: 'slug', redirect: 'http://www.example.com' } and
  # a publication type, either :new or :changed
  def self.publish(short_urls = {}, publisher = nil)
    publisher ||= AwsPublisher.new
    publisher.publish_redirects_for(short_urls)
  end

  def self.invalidate_cdn_cache_for(slug, publisher = nil)
    publisher ||= AwsPublisher.new
    publisher.create_cloudfront_invalidation_for slug
  end
end
