class AddPrioritizedClientColumnsToMatchRouteTable < ActiveRecord::Migration[6.1]
  def change
    add_column :match_routes, :prioritized_client_columns, :text

      MatchRoutes::Base.
  joins(:match_prioritization).
  pluck(:type, 'match_prioritizations.type').
  map do |route, column|
    puts route
    column_list = []
    priortitization = column.constantize
    column_list << priortitization.client_prioritization_summary_method if priortitization.client_prioritization_summary_method.present?
    if priortitization.supporting_data_columns.present?
      priortitization.supporting_data_columns.values.each do |v|
        # in this case, the columns are inside a Proc. Read the code to pull the column names
        file_name = v.source_location[0]
        line_number = v.source_location[1]
        code = IO.readlines(file_name)[line_number - 1].strip
        # Code is in the format: "'Match Group' => ->(client) { client.match_group },"
        code = code[code.index('{')..code.index('}')]
        code.slice!('{ client.')
        code.slice!('?')
        code.slice!(' }')
        column_list << code
      end
    end
    route.constantize.update_all(prioritized_client_columns: column_list)
  end
  end
end
