require 'rails_helper'

RSpec.describe "short_urls/new", type: :view do
  before(:each) do
    assign(:short_url, ShortUrl.new(
      :slug => "MyString",
      :redirect => "MyText"
    ))
  end

  it "renders new short_url form" do
    render

    assert_select "form[action=?][method=?]", short_urls_path, "post" do

      assert_select "input[name=?]", "short_url[slug]"

      assert_select "textarea[name=?]", "short_url[redirect]"
    end
  end
end
