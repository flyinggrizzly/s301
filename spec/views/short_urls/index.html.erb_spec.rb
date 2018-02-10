require 'rails_helper'

RSpec.describe "short_urls/index", type: :view do
  before(:each) do
    assign(:short_urls, [
      ShortUrl.create!(
        :slug => "Slug",
        :redirect => "MyText"
      ),
      ShortUrl.create!(
        :slug => "Slug",
        :redirect => "MyText"
      )
    ])
  end

  it "renders a list of short_urls" do
    render
    assert_select "tr>td", :text => "Slug".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
