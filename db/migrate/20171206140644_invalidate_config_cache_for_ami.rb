class InvalidateConfigCacheForAmi < ActiveRecord::Migration
  def up
    Config.invalidate_cache
  end
end
