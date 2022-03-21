class AdditionalTcHatFields < ActiveRecord::Migration[6.0]
  def change
    [
      :project_clients,
      :clients,
    ].each do |table|
      add_column table, :need_daily_assistance, :boolean, default: false
      add_column table, :full_time_employed, :boolean, default: false
      add_column table, :can_work_full_time, :boolean, default: false
      add_column table, :willing_to_work_full_time, :boolean, default: false
      add_column table, :rrh_successful_exit, :boolean, default: false
      add_column table, :th_desired, :boolean, default: false
      add_column table, :site_case_management_required, :boolean, default: false
      add_column table, :currently_fleeing, :boolean, default: false
      add_column table, :dv_date, :date
    end
  end
end
