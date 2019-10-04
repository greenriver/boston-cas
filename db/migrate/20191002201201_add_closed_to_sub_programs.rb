class AddClosedToSubPrograms < ActiveRecord::Migration
  def change
    add_column :sub_programs, :closed, :boolean, default: false
  end
end
