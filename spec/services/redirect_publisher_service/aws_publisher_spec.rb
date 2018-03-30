require 'rails_helper'

RSpec.describe RedirectPublisherService::AwsPublisher do

  describe 'public interface' do
    it 'responds to #publish'
    it 'responds to #unpublish'
    it 'responds to #cloudfront_invalidate'
    it 'responds to #cloudfront_invalidate_all'
  end

  describe '#publish' do
    it 'requires as a parameter a hash of short URL params [:slug, :redirect]'
    it 'does not accept a publication_type param'
    it 'sends a put_object request to S3'
    it 'invalidates the cloudfront cache for the slug'
  end

  describe '#unpublish' do
    it 'sends a destroy_object request to S3'
    it 'invalidates the cloudfront cache for the slug'
  end

  describe '#cloudfront_invalidate' do
    it 'sends a create_invalidation request to Cloudfront'
  end

  describe '#cloudfront_invalidate_all' do
    it 'calls #cloudfront_invalidate with a wildcard parameter'
  end
end
