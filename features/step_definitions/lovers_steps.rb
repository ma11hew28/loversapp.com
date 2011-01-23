Given /^I'm logged in$/ do
  @user = Lovers::User.auth(LoversTest::SIGNED_REQUEST)
  @user.fb_id.should == LoversTest::UID
end

Given /^I've sent the following requests:$/ do |table|
  table.hashes.each do |r|
    Lovers::Rel.new(r[:rid], @user.fb_id, r[:uid]).add_req
  end
end

Given /^I've received the following requests:$/ do |table|
  table.hashes.each do |r|
    Lovers::Rel.new(r[:rid], r[:uid], @user.fb_id).add_req
  end
end

Given /^I've hidden the following requests:$/ do |table|
  table.hashes.each do |r|
    Lovers::Rel.new(r[:rid], r[:uid], @user.fb_id).add_hid
  end
end

Given /^I'm in the following relationships:$/ do |table|
  table.hashes.each do |r|
    Lovers::Rel.new(r[:rid], @user.fb_id, r[:uid]).add_rel
  end
end

When /^I send a "(\d+)" request to user "(\d+)"$/ do |rid, uid|
  @code = @user.send_req(rid, uid)
end

When /^I confirm a "(\d+)" request from user "(\d+)"$/ do |rid, uid|
  @code = @user.conf_req(rid, uid)
end

When /^I hide a "(\d+)" request from user "(\d+)"$/ do |rid, uid|
  @code = @user.hide_req(rid, uid)
end

When /^I remove a "(\d+)" request from user "(\d+)"$/ do |rid, uid|
  @code = @user.remv_req(rid, uid)
end

When /^I remove a "(\d+)" relationship from user "(\d+)"$/ do |rid, uid|
  @code = @user.remv_rel(rid, uid)
end

Then /^I should have "(\d+)" sent requests?$/ do |num|
  @user.reqs_sent.count.should == num.to_i
end

Then /^I should have "(\d+)" received requests?$/ do |num|
  @user.reqs_recv.count.should == num.to_i
end

Then /^I should have "(\d+)" hidden requests?$/ do |num|
  @user.reqs_hidn.count.should == num.to_i
end

Then /^I should have "(\d+)" relationships?$/ do |num|
  @user.rels.count.should == num.to_i
end

Then /^the response code should be "(\d+)"$/ do |code|
  @code.should == code
end

# user authenticates himself

Given /^I'm not already authenticated$/ do
end

When /^I go to the canvas page$/ do
  @cookie = page.driver.post("/fb/canvas/", {
    'signed_request' => LoversTest::SIGNED_REQUEST
  }).headers['Set-Cookie'].gsub(/^.*rack.session=(.*?);.*$/, '\1')
end

When /^I'm authenticated$/ do
  @user = Lovers::User.auth(LoversTest::SIGNED_REQUEST)
end

Then /^I should be remembered$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be an app user$/ do
  @user = Lovers::User.auth(LoversTest::SIGNED_REQUEST)
  Lovers.redis.sismember("appUsrs", @user.fb_id).should be_true
end

