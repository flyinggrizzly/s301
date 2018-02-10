require 'redirect_publisher_service/aws_publisher'

# Provides methods for publishing short URLs to a static host
module RedirectPublisherService
  def self.publish_new(short_url = {})
    raise 'Short URL cannot be published without both slug and redirect' unless short_url.keys.sort.eql? %i[redirect slug]
    aws_connector = AwsPublisher.new
    aws_connector.publish(short_url, :new)
  end

  def self.publish_changed(short_url = {})
    raise 'Short URL cannot be published without both slug and redirect' unless short_url.keys.sort.eql? %i[redirect slug]
    aws_connector = AwsPublisher.new
    aws_connector.publish(short_url, :changed)
  end

  # Available publishers (defined in lib/redirect_publisher_service/*_publisher.rb)
  class AwsPublisher; end
end
