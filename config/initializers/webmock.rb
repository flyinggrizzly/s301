if Rails.env.test?
  require 'webmock'
  require 'webmock/rspec'
  WebMock.disable_net_connect!(allow_localhost: true)
end
