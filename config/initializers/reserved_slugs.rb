S301::Application.configure do
  core_reserved_slugs = %w[index unknown-short-url]
  instance_reserved_slugs = ENV['RESERVED_SLUGS'].split(',')
  instance_reserved_slugs.each do |slug|
    unless slug.match?(/^([a-z0-9]+([-_]?+[a-z0-9]+)?)*$/i)
      raise 'RESERVED_SLUG env var must have a value like "foo,bar,baz": comma-separated, no spaces, and only letters, numbers, "-" and "_"'
    end
  end
  config.reserved_slugs = core_reserved_slugs.push(*instance_reserved_slugs)
end
