class Race < ActiveRecord::Base
  self.table_name = 'primary_races'

  has_many :clients, primary_key: :numeric, foreign_key: :race_id
end
