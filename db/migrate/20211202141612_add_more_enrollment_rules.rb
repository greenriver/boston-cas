class AddMoreEnrollmentRules < ActiveRecord::Migration[6.0]
  def change
    [
      :project_clients,
      :clients,
    ].each do |table|
      [
        :enrolled_in_rrh,
        :enrolled_in_psh,
        :enrolled_in_ph,
      ].each do |column|
        add_column table, column, :boolean, default: false
      end
    end
  end
end
