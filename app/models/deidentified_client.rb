class DeidentifiedClient < ActiveRecord::Base
  validates :client_identifier, uniqueness: true
  has_one :project_client, ->  do
    where(
      data_source_id: DataSource.where(db_identifier: 'Deidentified').select(:id),
    )
  end, foreign_key: :id_in_data_source, required: false
  has_one :client, through: :project_client, required: false
  has_many :client_opportunity_matches, through: :client
  
  has_paper_trail
  acts_as_paranoid
  
  def involved_in_match?
    client_opportunity_matches.exists?
  end
end
