###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module HasMatchAccessContext
  extend ActiveSupport::Concern

  included do
    attr_accessor :match, :decision, :access_context
    helper MatchAccessContextsHelper

    delegate :current_contact,
      :match_scope,
      to: :access_context
  end

  def require_match_access_context!
    # build a MatchAccessContext from the current controller
    @access_context = MatchAccessContexts.build(self)
    @access_context.authenticate!
  end

end
