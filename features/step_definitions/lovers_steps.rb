Given /^I'm logged in$/ do
  @user = Lovers::User.new
  # example signed request Facebook sent via POST request to FB_CANVAS_URL
  signed_request = "FG1uGHoaGeNH2lxcfJG8AU1MBosRPTf_Wf6R5HQo-2Y.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyOTQ1MTY4MDAsImlzc3VlZF9hdCI6MTI5NDUxMjQ3Miwib2F1dGhfdG9rZW4iOiIxMjAwMjc3NDU0MzB8Mi5FS1NJd2FOZ21GN1c3aF9pTV9BM2Z3X18uMzYwMC4xMjk0NTE2ODAwLTUxNDQxN3xHV3dUT3FzWnI1S1pSUTBwVWFEMVB3MjhZSDgiLCJ1c2VyIjp7ImxvY2FsZSI6ImVuX1VTIiwiY291bnRyeSI6InVzIn0sInVzZXJfaWQiOiI1MTQ0MTcifQ"
  @user.login(signed_request)
  # @user.fb_id.should == "514417"
end

Given /^I've sent the following requests:$/ do |table|
  table.hashes.each { |r| @user.send_request(r[:rid], r[:uid]) }
end

Given /^I've received the following requests:$/ do |table|
  table.hashes.each do |r|
    Lovers::Request.create(r[:rid], r[:uid], @user.fb_id)
  end
end

Given /^I'm in the following relationships:$/ do |table|
  table.hashes.each do |r|
    Lovers::Relationship.create(r[:rid], @user.fb_id, r[:uid])
  end
end

When /^I send a "(\d+)" request to user "(\d+)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^this request should exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the response code should be "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^this request should not exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^this relationship should exist$/ do
  pending # express the regexp above with the code you wish you had
end
