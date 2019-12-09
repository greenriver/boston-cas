###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class NonHmisAssessment < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid

  belongs_to :non_hmis_client
end