###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchDecisionReasons
  class AdministrativeCancel < Base

    def self.available
      @availble ||= active.to_a << MatchDecisionReasons::Other.first 
    end
  end
end