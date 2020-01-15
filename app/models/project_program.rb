###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ProjectProgram < ActiveRecord::Base

  belongs_to :building, required: false

end
