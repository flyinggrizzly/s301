require 'redirect_publisher_service/aws_publisher'

# Provides methods for publishing short URLs to a static host
module RedirectPublisherService
  # Accepts a hash { slug: 'slug', redirect: 'http://www.example.com' } and
  # a publication type, either :new or :changed
  def self.publish(short_url = {}, publication_type)
    raise_unless_short_url_parameters_valid(short_url, 'publish')
    raise '`publication_type` must be `:new` or `:changed`' unless %i[new changed].include? publication_type

    aws_publisher = AwsPublisher.new
    aws_publisher.publish(short_url, publication_type)
  end

  # Accepts a hash { slug: 'slug', redirect: 'http://www.example.com' }
  def self.unpublish(short_url = {})
    raise_unless_short_url_parameters_valid(short_url, 'unpublish')
    aws_publisher = AwsPublisher.new
    aws_publisher.unpublish(short_url)
  end

  private_class_method def self.short_url_vals_not_blank(short_url)
    short_url.each_value do |v|
      return false if v.blank?
    end
  end

  private_class_method def self.raise_unless_short_url_parameters_valid(short_url, publication_type)
    case publication_type
    when 'publish'
      msg = 'short URLs cannot be published without both slug and redirect'
    when 'unpublish'
      msg = 'short URLs cannot be unpublished without both slug and redirect'
    end
    raise msg unless short_url.keys.sort.eql? %i[redirect slug]
    raise msg unless short_url_vals_not_blank(short_url)
  end

  # Available publishers (defined in lib/redirect_publisher_service/*_publisher.rb)
  class AwsPublisher; end
end
