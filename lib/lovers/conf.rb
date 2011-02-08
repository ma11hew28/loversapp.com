require 'settingslogic'
module Lovers
  class Conf < Settingslogic
    source    "#{Lovers.root}/lovers.yml"
    namespace Lovers.env
  end
end
