# Validates URLs by checking they have a host
class UrlValidator < ActiveModel::EachValidator
  require 'addressable'

  def validate_each(record, attribute, value)
    return if validate_url(value)
    record.errors.add(attribute, (options[:message] || :url_format))
  end

  private

  def validate_url(value)
    return false if value.blank?

    url = Addressable::URI.heuristic_parse(value)
    url.host.present?
  rescue URI::InvalidURIError
    false
  end
end
