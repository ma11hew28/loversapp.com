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
