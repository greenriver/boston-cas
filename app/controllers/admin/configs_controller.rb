###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Admin
  class ConfigsController < ApplicationController
    before_action :require_can_manage_config!
    before_action :set_config

    def index

    end

    def update
      if @config.update(config_params)
        redirect_to({action: :index}, notice: 'Configuration updated')
      else
        render action: :index, error: 'The configuration failed to save.'
      end
    end

    private def config_params
      p = params.require(:config).permit(
        :dnd_interval,
        :warehouse_url,
        :require_cori_release,
        :ami,
        :vispdat_prioritization_scheme,
        non_hmis_fields: [],
      )
    end

    def set_config
      @config = config_source.where(id: 1).first_or_create
    end

    def config_source
      Config
    end

  end
end
