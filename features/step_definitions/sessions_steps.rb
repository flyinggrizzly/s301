When /^I sign in with the following information:$/ do |info|
  info = info.raw.to_h
  page.fill_in 'session_email', with: info['email']
  page.fill_in 'session_password', with: info['password']
  page.click 'Sign in'
end
