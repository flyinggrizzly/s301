Then /^I should see a link in the email sent to "(\w+)@(\w+).([a-z]+)" that takes me back to the application and confirms my account$/ do |address|
  open_email address
  click_first_link_in_email
  expect(page).to have_content(address)
end

Then /^I should be logged in$/ do
  expect(page).to have_link 'Sign out'
end
