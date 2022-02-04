###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include ArelHelper
end
