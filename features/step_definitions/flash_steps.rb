Then /^I should see a flash that says "([ \w]+)"$/ do |flash|
  expect(page).to have_content(flash)
end
