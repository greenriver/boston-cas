class AddEncampmentDecomissionedToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :encampment_decomissioned, :boolean, default: false
  end
end
