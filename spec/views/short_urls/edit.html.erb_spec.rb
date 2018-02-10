require 'rails_helper'

RSpec.describe "short_urls/edit", type: :view do
  before(:each) do
    @short_url = assign(:short_url, ShortUrl.create!(
      :slug => "MyString",
      :redirect => "MyText"
    ))
  end

  it "renders the edit short_url form" do
    render

    assert_select "form[action=?][method=?]", short_url_path(@short_url), "post" do

      assert_select "input[name=?]", "short_url[slug]"

      assert_select "textarea[name=?]", "short_url[redirect]"
    end
  end
end
