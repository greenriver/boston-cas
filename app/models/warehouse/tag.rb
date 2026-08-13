###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module Warehouse
  class Tag < Base
    scope :available, -> { all }
  end
end
