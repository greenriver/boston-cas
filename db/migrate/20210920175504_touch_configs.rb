class TouchConfigs < ActiveRecord::Migration[6.0]
  def up
    Config.first.save if Config.first
  end
end
