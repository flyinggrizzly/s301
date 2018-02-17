require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ShortUrlsHelper. For example:
#
# describe ShortUrlsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ShortUrlsHelper, type: :helper do
  describe '#endpoint_for' do

    around(:each) do |ex|
      endpoint = S301::Application.config.endpoint
      S301::Application.config.endpoint = 'https://s301.net'
      ShortUrl.skip_callback(:save, :after, :publish)
      ex.run
      ShortUrl.set_callback(:save, :after, :publish)
      S301::Application.config.endpoint = endpoint
    end

    context 'given a short URL object' do
      it 'returns the endpoint URL for that short URL' do
        su = create(:short_url)

        expect(endpoint_for(su)).to eq("https://s301.net/#{su.slug}")
      end
    end
  end
end
