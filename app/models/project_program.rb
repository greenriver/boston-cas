###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class ProjectProgram < ApplicationRecord

  belongs_to :building, optional: true

end
