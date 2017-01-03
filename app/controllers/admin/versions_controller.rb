module Admin
  class VersionsController < ApplicationController
    before_action :require_can_act_on_behalf_of_match_contacts!

    def index
      @versions = PaperTrail::Version.
        preload(:item).
        order(created_at: :desc).
        page(params[:page]).per(25)
    end
  end
end