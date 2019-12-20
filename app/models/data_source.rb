###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class DataSource < ApplicationRecord

  belongs_to :building
  has_many :building_clients
  has_many :project_clients

  validates_presence_of :name

  scope :non_hmis, -> do
    where(db_identifier: 'Deidentified')
  end

end
