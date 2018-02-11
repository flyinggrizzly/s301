require 'redirect_publisher_service/aws_publisher'

# Provides methods for publishing short URLs to a static host
module RedirectPublisherService
  def self.publish(short_url = {}, publication_type)
    raise 'short URLs cannot be published without both slug and redirect' unless short_url.keys.sort.eql? %i[redirect slug]
    raise '`publication_type` must be `:new` or `:changed`' unless %i[new changed].include? publication_type

    aws_publisher = AwsPublisher.new
    aws_publisher.publish(short_url, publication_type)
  end

  def self.publish_new(short_url = {})
    raise 'Short URL cannot be published without both slug and redirect' unless short_url.keys.sort.eql? %i[redirect slug]
    aws_publisher = AwsPublisher.new
    aws_publisher.publish(short_url, :new)
  end

  def self.publish_changed(short_url = {})
    raise 'Short URL cannot be published without both slug and redirect' unless short_url.keys.sort.eql? %i[redirect slug]
    aws_publisher = AwsPublisher.new
    aws_publisher.publish(short_url, :changed)
  end

  # Available publishers (defined in lib/redirect_publisher_service/*_publisher.rb)
  class AwsPublisher; end
end
