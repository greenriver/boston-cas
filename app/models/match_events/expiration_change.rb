###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchEvents
  class ExpirationChange < Base
    validates :note, presence: true
    
    def name
      note
    end
        
  end
end