When /^I enter the following user information:$/ do |info|
  info = info.raw.to_h
  page.fill_in 'Email', with: info['email']
  page.fill_in 'Password', with: info['password']
  page.click_on 'Sign up'
end
