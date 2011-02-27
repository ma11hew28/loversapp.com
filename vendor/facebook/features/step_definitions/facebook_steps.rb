# user authenticates himself

Given /^I'm not an app user$/ do
  @signed_request = Facebook::Test::NON_USER[:signed_request]
end

When /^I go to the canvas page$/ do
  begin
    request = FB_TEST_APP.decode_signed_request(@signed_request)
    @user_id = request["user_id"] unless request["issued_at"].nil?
  rescue Facebook::AuthenticationError => e
    @error_class = e.class
  end
end

Then /^I should not be authenticated$/ do
  @user_id.should be_nil and @error_class.should be_nil
end

Given /^I'm an app user$/ do
  @signed_request = Facebook::Test::APP_USER[:signed_request]
end

Then /^I should be (authenticated|remembered)$/ do |x|
  @user_id.should eql(Facebook::Test::APP_USER[:user_id])
end

Given /^I'm already authenticated$/ do
  @signed_request = FB_TEST_APP.user_cookie(Facebook::Test::APP_USER[:user_id])
end

Given /^I'm a malicious user$/ do
  @signed_request = Facebook::Test::MAL_USER[:signed_request]
end

Then /^I should get a Facebook::AuthenticationError$/ do
  @error_class.should equal(Facebook::AuthenticationError)
end

# apprequests

Given /^I'm logged in$/ do
  @user = Facebook::User.new(Facebook::Test::APP_USER[:user_id],
    Facebook::Test::APP_USER[:access_token])
end

When /^I view my apprequests$/ do
  @apprequests = @user.apprequests
end

Then /^I should see "(\d+)" apprequests$/ do |reqs|
  @apprequests.should have(Integer(reqs)).apprequests
end
