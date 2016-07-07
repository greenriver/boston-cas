class Ethnicity < ActiveRecord::Base
  has_many :clients, primary_key: :numeric, foreign_key: :ethnicity_id
end
