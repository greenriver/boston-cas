class MatchesController < ApplicationController
  include HasMatchAccessContext
  include Decisions
  include MatchShow
  include PjaxModalController

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

  def has_unit?
    voucher.unit
  end
  helper_method :has_unit?

  def default_building_id
    voucher.unit.building
  end
  helper_method :default_building_id

  def default_unit_id
    voucher.unit.id
  end
  helper_method :default_unit_id

  def default_unit_name
    voucher.unit.name
  end
  helper_method :default_unit_name

  def candidate_units
    units = [ Unit.find(default_unit_id) ]
    units += voucher.units.select{|u| !u.in_use? }
  end
  helper_method :candidate_units


  private

    def voucher
      match.opportunity.voucher
    end

    def find_match!
      @match = match_scope.find(params[:id])
    end

    def prevent_page_caching
      response.headers['Cache-Control'] = 'private, max-age=0, no-cache, no-store'
    end

end
