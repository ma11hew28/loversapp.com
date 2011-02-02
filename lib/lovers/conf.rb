require 'settingslogic'
module Lovers
  class Conf < Settingslogic

    source    "#{Lovers.root}/lovers.yml"
    namespace Lovers.env

    class << self
      def fb_canvas_page
        "http://apps.facebook.com/#{fb_canvas_name}"
      end
    end
  end

  class << self
    def fb
      @@fb ||= Facebook::Application.new(
        Lovers::Conf.fb_app_id, Lovers::Conf.fb_app_secret)
    end    
  end    
end
