class Config < ActiveRecord::Base
  after_save :invalidate_cache
  before_create :set_defaults

  def invalidate_cache
    self.class.invalidate_cache
  end

  def set_defaults    
    self.dnd_interval  ||= if Rails.env.production?
      7 #days
    else
      1
    end
    
    self.warehouse_url = "https://hmis.boston.gov"
  end
  
  def self.invalidate_cache
    Rails.cache.delete(self.name)
  end

  def self.get(config)
    @settings = Rails.cache.fetch(self.name) do
      self.first_or_create
    end
    @settings.public_send(config)
  end
end
