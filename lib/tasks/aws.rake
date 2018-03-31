require 'redirect_publisher_service'

namespace :cloudfront do
  include RedirectPublisherService

  # usage: rake cloudfront:invalidate RESOURCE=object_to_invalidate
  desc 'Invalidate a cloudfront item'
  task :invalidate do
    object = ENV['RESOURCE']
    aws_publisher = RedirectPublisherService::AwsPublisher.new
    printf 'Invalidation response: '
    puts aws_publisher.create_cloudfront_invalidation_for(object).inspect
  end

  desc 'Invalidate all cloudfront items'
  task :invalidate_all do
    ENV['RESOURCE'] = '*'
    Rake::Task['cloudfront:invalidate'].invoke
  end
end
