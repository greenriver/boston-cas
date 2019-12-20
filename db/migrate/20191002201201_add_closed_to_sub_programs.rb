class AddClosedToSubPrograms < ActiveRecord::Migration[4.2]
  def change
    add_column :sub_programs, :closed, :boolean, default: false
  end
end
