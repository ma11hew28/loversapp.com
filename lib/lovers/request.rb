module Lovers
  class Request
    attr_accessor :rid, :uid # request_id, user_id

    def initialize(rid, uid)
      self.rid = rid
      self.uid = uid
    end
  end
end
