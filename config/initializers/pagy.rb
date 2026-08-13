###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# Rails.logger.debug "Running initializer in #{__FILE__}"
require 'pagy/extras/bootstrap'
require 'pagy/extras/array'

Pagy::DEFAULT[:items] = 25 # items per page
