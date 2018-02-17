source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.5'

gem 'jbuilder',   '~> 2.5'
gem 'pg',         '~> 0.18'
gem 'puma',       '~> 3.7'
gem 'turbolinks', '~> 5'

gem 'coffee-rails', '~> 4.2'
gem 'sass-rails',   '~> 5.0'
gem 'uglifier',     '>= 1.3.0'

gem 'foundation-rails',         '~> 6.3'
gem 'will_paginate',            '~> 3.1'
gem 'will_paginate-foundation', '~> 6.2'

gem 'addressable'
gem 'aws-sdk-cloudfront'
gem 'aws-sdk-s3'
gem 'dotenv-rails'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
