class InvalidateConfigCacheForCori < ActiveRecord::Migration[4.2]
  def change
    Config.invalidate_cache
  end
end
