class DataSource < ActiveRecord::Base

  belongs_to :building
  has_many :building_clients

  validates_presence_of :name

end
