class InvalidateConfigCacheForAmi < ActiveRecord::Migration[4.2]
  def up
    Config.invalidate_cache
  end
end
