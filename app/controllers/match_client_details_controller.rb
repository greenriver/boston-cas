class MatchClientDetailsController < ApplicationController
  include HasMatchAccessContext
  include PjaxModalController

  before_action :require_match_access_context!

  before_action :set_match
  before_action :set_client

  def show
  end

  private

    def set_match
      @match = match_scope.find params[:match_id]
    end

    def set_client
      @client = @match.client
    end

end
