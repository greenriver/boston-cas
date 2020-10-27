class TestFail < ActiveRecord::Migration[6.0]
  def change
    raise "test fail"
  end
end
