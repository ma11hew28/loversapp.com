Given /^I'm logged in$/ do
  @user = Lovers::User.auth!(LoversTest::SIGNED_REQUEST)
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

When /^I remove a "(\d+)" relationship with user "(\d+)"$/ do |rid, uid|
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

Given /^I'm (not )?already authenticated$/ do |skip|
  @user = Lovers::User.auth!(LoversTest::SIGNED_REQUEST) unless skip
end

When /^I go to the canvas page$/ do
  @cookie = page.driver.post("/fb/canvas/", {
    'signed_request' => LoversTest::SIGNED_REQUEST
  }).headers['Set-Cookie'].gsub(/^.*rack.session=(.*?);.*$/, '\1')
end

# Then /^I should be remembered$/ do
#   @cookie.should == LoversTest::COOKIE
# end

Then /^I should be an app user$/ do
  Lovers.redis.sismember("appUsrs", LoversTest::UID).should be_true
end

When /^I click on the Lovers tab$/ do
  puts page.driver.get("/fb/canvas/rels")
end

Given /^I've sent the following gifts:$/ do |table|
  table.hashes.each do |g|
    Lovers::Gift.new(g[:gid], @user.fb_id, g[:uid]).add
  end
end

When /^I send a "(\d+)" gift to user "(\d+)"$/ do |gid, uid|
  @code = @user.send_gift(gid, uid)
end

Then /^I should have "(\d*)" sent gifts$/ do |num|
  sum = 0
  @user.gifts_sent.each_with_index { |s, i| sum += s.to_i if i.odd? }
  sum.should == num.to_i
end
