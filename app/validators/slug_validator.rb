# Validates Short URL Slugs
class SlugValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    return if validate_slug(value)
    record.errors.add(attribute, (options[:message] || :slug_format))
  end

  private

  def validate_slug(value)
    return false if reserved_slug?(value)
    uses_valid_chars?(value) ? true : false
  rescue StandardError
    false
  end

  def reserved_slug?(slug)
    S301::Application.config.reserved_slugs.include? slug
  end

  def uses_valid_chars?(slug)
    # ensure all slugs include only a-z, 0-9, and - or _
    slug.match(/^([a-z0-9]+([-_]?+[a-z0-9]+)?)*$/i)
  end
end
