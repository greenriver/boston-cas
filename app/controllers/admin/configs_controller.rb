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
        :ami
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
