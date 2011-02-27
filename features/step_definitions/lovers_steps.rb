Given /^I'm logged in$/ do
  @user = Lovers::User.auth!(LoversTest::SIGNED_REQUEST)
  @user.facebook.id.should eq(LoversTest::UID)
end

Given /^I've sent the following requests:$/ do |table|
  table.hashes.each do |r|
    # Lovers::Relationship.new(r[:rid], @user.facebook.id, r[:uid]).add_req
  end
end

Given /^I've received the following requests:$/ do |table|
  table.hashes.each do |r|
    # Lovers::Relationship.new(r[:rid], r[:uid], @user.facebook.id).add_req
  end
end

Given /^I'm in the following relationships:$/ do |table|
  table.hashes.each do |r|
    Lovers::Relationship.new(r[:rid], @user.facebook.id, r[:uid]).save
  end
end

When /^I send a "(\d+)" request to user "(\d+)"$/ do |rid, uid|
  # @code = @user.send_req(rid, uid)
end

# How do we mock user_id here?
When /^I accept request "(\d+)"$/ do |request_id|
  @code = @user.accept_requests(request_id)
end

When /^I reject a "(\d+)" request from user "(\d+)"$/ do |rid, uid|
  # @code = @user.remove_request(rid, uid)
end

When /^I remove a "(\d+)" relationship with user "(\d+)"$/ do |rid, uid|
  @code = @user.remove_relationship(rid, uid)
end

Then /^I should have "(\d+)" sent requests?$/ do |num|
  # @user.reqs_sent.count.should == num.to_i
end

Then /^I should have "(\d+)" received requests?$/ do |num|
  # @user.reqs_recv.count.should == num.to_i
end

Then /^I should have "(\d+)" relationships?$/ do |num|
  @user.relationships.count.should == num.to_i
end

Then /^the response code should be "(\d+)"$/ do |code|
  @code.should == code
end

# user authenticates himself

Given /^I'm (not )?already authenticated$/ do |skip|
  @user = Lovers::User.auth!(LoversTest::SIGNED_REQUEST) unless skip
end

When /^I go to the canvas page$/ do
  response = page.driver.post("/fb/canvas/", {
    "signed_request" => LoversTest::SIGNED_REQUEST
  })
  @cookie = response.headers["Set-Cookie"].sub(/^u=(.*)\; domain.*$/, '\1')
end

Then /^I should be remembered$/ do
  Lovers::User.auth!(@cookie).id.should eq(LoversTest::UID)
end

Then /^I should be an app user$/ do
  Lovers.redis.sismember("users", LoversTest::UID).should be_true
end

When /^I click on the Lovers tab$/ do
  puts page.driver.get("/fb/canvas/rels")
end

When /^I send an invalid signed_request$/ do
  @code = page.driver.post("/fb/canvas/", {
    "signed_request" => "invalid signed request"
  })
end

Given /^I've sent the following gifts:$/ do |table|
  table.hashes.each do |g|
    @user.send_gift(g[:gid], g[:uid])
  end
end

When /^I send a "(\d+)" gift to user "(\d+)"$/ do |gid, uid|
  @code = @user.send_gift(gid, uid)
end

Then /^I should have "(\d*)" sent gifts$/ do |sent|
  @user.sent_gifts_count
end

Given /^the following users exist:$/ do |table|
  @users = []
  table.hashes.each do |u|
    @users << Lovers::User.new(u[:uid]).tap { |u| u.save }
  end
end

Given /^user "(\d*)" has sent gift "(\d*)" to user "(\d*)"$/ do |uid, gid, tid|
  Lovers::User.new(uid).send_gift(gid, tid)
end

Then /^user "(\d*)" should have "(\d*)" sent gifts$/ do |uid, sent|
  Lovers::User.new(uid).sent_gifts_count.should equal(Integer(sent))
end

Then /^user "(\d*)" should have "(\d*)" received gifts$/ do |uid, recv|
  Lovers::User.new(uid).received_gifts_count.should equal(Integer(recv))
end

Then /^I should have "(\d*)" points$/ do |pts|
  @user.points.should equal(Integer(pts))
end

Then /^user "(\d*)" should have "(\d*)" points$/ do |uid, pts|
  Lovers::User.new(uid).points.should equal(Integer(pts))
end

Then /^user "(\d*)" should have "(\d*)" proactive points$/ do |uid, pts|
  Lovers::User.new(uid).proactive_points.should equal(Integer(pts))
end

Then /^user "(\d*)" should have "(\d*)" attracted points$/ do |uid, pts|
  Lovers::User.new(uid).attracted_points.should equal(Integer(pts))
end

Given /^the following gifts have been sent:$/ do |table|
  table.hashes.each do |g|
    Lovers::User.new(g[:uid]).send_gift(g[:gid], g[:tid])
  end
end

When /^the points are calculated & saved for each user$/ do
  Lovers::User.calculate_points_once
  # @users.each do |u|
  #   u.calculate_points
  #   u.save_points
  # end
end

Then /^the points should be:$/ do |table|
  table.hashes.each do |u|
    # Check points from object.
    user = @users.find { |usr| usr.facebook.id == u[:uid] }
    user.points.should equal(Integer(u[:pts]))
    user.proactive_points.should equal(Integer(u[:pro]))
    user.attracted_points.should equal(Integer(u[:atr]))

    # Check points from database.
    user = Lovers::User.new(u[:uid])
    user.points.should equal(Integer(u[:pts]))
    user.proactive_points.should equal(Integer(u[:pro]))
    user.attracted_points.should equal(Integer(u[:atr]))
  end
end
