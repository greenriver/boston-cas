class DataSource < ActiveRecord::Base

  belongs_to :building
  has_many :building_clients
  has_many :project_clients

  validates_presence_of :name

  scope :non_hmis, -> do
    where(db_identifier: 'Deidentified')
  end

end
