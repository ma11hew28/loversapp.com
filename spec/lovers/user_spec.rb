require 'spec_helper'

describe Array do
  let(:array) { ["0|2", "4", "1|2", "2", "2|2", "1", "3|2", "1"] }

  describe "#sum_odds"

  describe "#sum_points" do
    it "sums points of gifts in array" do
      array.sum_points.should equal(4+22+100+3305)
    end
  end
end

module Lovers
  describe User do
    let(:user) { User.new("1") }

    describe "::count" do
      it "returns the count of users in the database" do
        1.upto(3) { |u| User.create(u) }
        User.count.should equal(3)
      end
    end

    describe "::paginate" do
      before(:each) { 1.upto(100) { |u| User.create(u) } }

      it "defaults to 20 per-page, sorted ASC (from smallest to largest)" do
        User.paginate.should eql(("1".."20").to_a)
      end

      it "takes a page option" do
        User.paginate(page: 3).should eql(("41".."60").to_a)
      end

      it "takes a per_page option" do
        User.paginate(per_page: 3).should eql(("1".."3").to_a)
      end
    end

    context "leader board" do
      leaders = ("1".."20").to_a

      describe "::top_lovers" do
        it "returns the top-ten users by points" do
          Lovers.redis.should_receive(:zrevrange).
            with("points", 0, 9, with_scores: true) { leaders }
          User.top_lovers.should equal(leaders)
        end
      end

      describe "::most_loving" do
        it "returns the top-ten users by points" do
          Lovers.redis.should_receive(:zrevrange).
            with("proactivePoints", 0, 9, with_scores: true) { leaders }
          User.most_loving.should equal(leaders)
        end
      end

      describe "::most_loved" do
        it "returns the top-ten users by points" do
          Lovers.redis.should_receive(:zrevrange).
            with("attractedPoints", 0, 9, with_scores: true) { leaders }
          User.most_loved.should equal(leaders)
        end
      end
    end

    describe "#admin?" do
      it "returns true if the user is an administrator" do
        User.new(Conf.admin_uids[0]).admin?.should be_true
      end
    end

    describe "#save" do
      it 'adds itself to the "users" set' do
        user.save
        Lovers.redis.sismember("users", user.facebook.id).should be_true
      end

      it 'removes itself from the "alums" set' do
        Lovers.redis.sadd("alums", user.facebook.id)
        user.save
        Lovers.redis.sismember("alums", user.facebook.id).should be_false
      end
    end

    describe "#delete" do
      it 'removes itself from the "users" set' do
        Lovers.redis.sadd("users", user.facebook.id)
        user.delete
        Lovers.redis.sismember("users", user.facebook.id).should be_false
      end

      it 'adds itself to the "alums" set' do
        user.delete
        Lovers.redis.sismember("alums", user.facebook.id).should be_true
      end
    end

    describe "#calculate_points" do
      it "calculates a user's points" do
        user.should_receive(:calculate_proactive_points).and_return(100)
        user.should_receive(:calculate_attracted_points).and_return(201)
        user.calculate_points.should equal(301)
      end
    end

    describe "#calculate_proactive_points" do
      it "calculates a user's proactive points" do
        sent_gifts = double("sent_gifts_array")
        user.should_receive(:sent_gifts).and_return(sent_gifts)
        sent_gifts.should_receive(:sum_points).and_return(100)
        user.calculate_proactive_points.should equal(100)
      end
    end
  end
end
