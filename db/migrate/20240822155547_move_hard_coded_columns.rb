class MoveHardCodedColumns < ActiveRecord::Migration[7.0]
  def up
    existing_columns = [
      :assessment_type_description,
      :required_number_of_bedrooms_or_sro_ok,
    ]
    existing_columns << :required_minimum_occupancy unless Config.get(:identified_client_assessment).include?('Pathways')
    MatchRoutes::Base.find_each do |r|
      previous_columns = r.prioritized_client_columns || []
      visible_columns = existing_columns + previous_columns
      r.update!(prioritized_client_columns: visible_columns.uniq)
    end
  end
end
