class VeteranStatus < ActiveRecord::Base
  has_many :clients, primary_key: :numeric, foreign_key: :veteran_status_id
end
