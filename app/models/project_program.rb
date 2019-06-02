###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ProjectProgram < ActiveRecord::Base

  belongs_to :building, required: false

end
