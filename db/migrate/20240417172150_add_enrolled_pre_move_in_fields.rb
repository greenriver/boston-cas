class AddEnrolledPreMoveInFields < ActiveRecord::Migration[6.1]
  def change
    [:project_clients, :clients].each do |table|
      [
        :enrolled_in_ph_pre_move_in,
        :enrolled_in_psh_pre_move_in,
        :enrolled_in_rrh_pre_move_in,
      ].each do |col|
        add_column table, col, :boolean, default: false, null: false
      end
    end
  end
end
