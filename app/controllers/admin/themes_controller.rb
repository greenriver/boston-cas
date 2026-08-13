###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Admin
  class ThemesController < ApplicationController
    before_action :require_can_manage_config!
    before_action :set_theme

    def index
    end

    def update
      if @theme.update(theme_params)
        redirect_to({ action: :index }, notice: 'Theme updated')
      else
        render action: :index
      end
    end

    private def theme_params
      params.require(:theme).permit(
        :logo,
        :favicon_32,
        :favicon_16,
        :favicon_ico,
        :homepage_content,
        :css,
      )
    end

    private def set_theme
      @theme = Theme.where(client: ENV['CLIENT']).first_or_create
    end
  end
end
