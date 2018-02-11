require 'redirect_publisher_service/aws_publisher'

namespace :cloudfront do
  include RedirectPublisherService

  # usage: rake cloudfront:invalidate RESOURCE=object_to_invalidate
  desc 'Invalidate a cloudfront item'
  task :invalidate do
    object = ENV['RESOURCE']
    aws_publisher = RedirectPublisherService::AwsPublisher.new
    printf 'Invalidation response: '
    puts aws_publisher.cloudfront_invalidate(object).inspect
  end

  desc 'Invalidate all cloudfront items'
  task :invalidate_all do
    ENV['RESOURCE'] = '*'
    Rake::Task['cloudfront:invalidate'].invoke
  end
end
