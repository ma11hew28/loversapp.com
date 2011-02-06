module Lovers
  class Relationship

    # TYPES
    IN_A_RELATIONSHIP = 0
    ENGAGED = 1
    MARRIED = 2
    ITS_COMPLICATED = 3
    IN_AN_OPEN_RELATIONSHIP = 4

    def self.sign_code(info)
      Digest::SHA256.hexdigest("#{info}#{Lovers::Conf.rel_secret}")
    end

    # Given a from_id and relationship_id, generate a signed relationship code.
    def self.signed_code_for_user(relationship_id, from_id)
      info = "#{relationship_id},#{from_id},#{Time.now.to_i}"
      "#{info}|#{sign_code(info)}"
    end

    def self.code_hash_for_user(from_id)
      (0..4).collect do |relationship_id|
        signed_code_for_user(relationship_id, from_id)
      end
    end

    # Given the from_id of a user who received a request and the code that she
    # received, create a new relationship from the original user to this user.
    def self.create_from_code(to_id, code)
      info, sig = code.split('|')
      if sig == sign_code(info)
        relationship_id, from_id, ts = info.split(',')
        rel = new(relationship_id, from_id, to_id)
        rel if rel.save
      end
    end

    RELS = "relationships" # name.split('::').last.uncapitalize.pluralize

    # attr_accessor :relationship_id, :user_id_1, :user_id_2

    def initialize(relationship_id, user_id_1, user_id_2)
      @relationship_id = relationship_id
      @user_id_1, @user_id_2 = user_id_1, user_id_2
    end

    # def self.create(relationship_id, user_id_1, user_id_2)
    #   self.new(relationship_id, user_id_1, user_id_2).tap { |r| r.save_rel }
    # end

    # For each user in couple, store relationships in sorted set of user_ids.
    # relationship_id is SCORE. Alternative: Use sets of user_ids & a key
    # (user_id_1:user_id_2, where user_id_1 < user_id_2) to relationship_id for
    # each couple. I chose zsets for ease of implementation & speed.
    def save
      Lovers.redis.zadd(@user_id_1+":"+RELS, @relationship_id, @user_id_2) &&
      Lovers.redis.zadd(@user_id_2+":"+RELS, @relationship_id, @user_id_1)
    end

    def delete
      Lovers.redis.zrem(@user_id_1+":"+RELS, @user_id_2) &&
      Lovers.redis.zrem(@user_id_2+":"+RELS, @user_id_1)
    end

    def rel_exists?
      Lovers.redis.zscore(@user_id_1+":"+RELS, @user_id_2) &&
      Lovers.redis.zscore(@user_id_2+":"+RELS, @user_id_1)
    end

    def rel_exact?
      @relationship_id == Lovers.redis.zscore(@user_id_1+":"+RELS, @user_id_2) &&
      @relationship_id == Lovers.redis.zscore(@user_id_2+":"+RELS, @user_id_1)
    end
  end
end
