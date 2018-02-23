Given /^I am on the "(\w+)" page$/ do |page|
  visit send("#{page}_path")
  save_page
end

When /^I click "([ \w]+)"/ do |link_text|
  page.click_on link_text
end

When /^I navigate to the "(\w+)" page$/ do |page|
  visit send("#{page}_path")
  save_page
end
