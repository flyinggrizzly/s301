require 'rails_helper'

RSpec.describe "short_urls/show", type: :view do
  before(:each) do
    @short_url = assign(:short_url, ShortUrl.create!(
      :slug => "Slug",
      :redirect => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Slug/)
    expect(rendered).to match(/MyText/)
  end
end
