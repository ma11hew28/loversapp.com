require 'spec_helper'

class Facebook
  describe User do
    let(:user) { User.new("1", "mock_access_token") }

    describe "#apprequests" do
      it "memoizes the Graph API response" do
        user.should_receive(:get) { [] }
        user.apprequests
        user.apprequests
      end
    end

    describe "#api" do
      it "gets user's basic info without an access token" do
        user.instance_variable_set(:@access_token, nil)
        Facebook.should_receive(:api).with("/#{user.id}", {}, "GET")
        user.get
      end

      it "gets user's apprequests" do
        Facebook.should_receive(:api).with("/#{user.id}/apprequests",
          {access_token: user.access_token}, "GET")
        user.get("apprequests")
      end
    end
  end
end
