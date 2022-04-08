class AddAssessorInfo < ActiveRecord::Migration[6.0]
  def change
    [:project_clients, :clients].each do |table|
      add_column table, :assessor_first_name, :string
      add_column table, :assessor_last_name, :string
      add_column table, :assessor_email, :string
      add_column table, :assessor_phone, :string
    end
  end
end
