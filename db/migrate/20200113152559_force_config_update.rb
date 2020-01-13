class ForceConfigUpdate < ActiveRecord::Migration
  def change
    Config.invalidate_cache
  end
end
