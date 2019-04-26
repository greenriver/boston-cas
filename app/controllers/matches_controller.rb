class MatchesController < ApplicationController
  include HasMatchAccessContext
  include Decisions
  include MatchShow
  include PjaxModalController
  include MatchBuildingAndUnit

  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :find_match!, only: [:show]
  before_action :prevent_page_caching

  def show
    prep_for_show
  end


  def history
    @match = match_scope.find(params[:match_id])
    @types = MatchRoutes::Base.match_steps
    render layout: false
  end

  def cant_edit_self?
    ! current_contact.user_can_edit_match_contacts? && hsa_can_edit_contacts?
  end
  helper_method :cant_edit_self?

  private

    def find_match!
      @match = match_scope.find(params[:id])
    end

    def prevent_page_caching
      response.headers['Cache-Control'] = 'private, max-age=0, no-cache, no-store'
    end

end
