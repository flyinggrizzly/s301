require 'rails_helper'

WebMock.disable_net_connect!(allow_local_host: true)

RSpec.describe RedirectPublisherService do
  describe 'public interface' do
    it 'responds to ::publish' do
      expect(RedirectPublisherService).to respond_to(:publish)
    end

    it 'responds to ::unpublish' do
      expect(RedirectPublisherService).to respond_to(:unpublish)
    end
  end

  it 'includes an AWS publisher' do
    expect(RedirectPublisherService::AwsPublisher).to be_an_instance_of(Class)
  end
end
