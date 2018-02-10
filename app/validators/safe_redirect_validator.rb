# Validates that URLs won't create redirect loops
class SafeRedirectValidator < ActiveModel::EachValidator
  require 'addressable'

  def validate_each(record, attribute, value)
    return if validate_safe_redirect(value)
    record.errors.add(attribute, (options[:message] || :redirecting_to_app_host))
  end

  private

  def validate_safe_redirect(value)
    # Blacklist currently consists of just the application domain
    app_host = URI.parse(S301::Application.config.app_host).host
    redirect = Addressable::URI.heuristic_parse(value)

    redirect.host != app_host
  rescue StandardError
    false
  end
end
