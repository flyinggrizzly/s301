module ShortUrlsHelper
  # Returns the URL of the short URL at the application endpoint
  def endpoint_for(short_url)
    S301::Application.config.endpoint + '/' + short_url.slug
  end
end
