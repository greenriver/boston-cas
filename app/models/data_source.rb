###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class DataSource < ApplicationRecord
  belongs_to :building
  has_many :building_clients
  has_many :project_clients

  validates_presence_of :name

  scope :non_hmis, -> do
    where(db_identifier: 'Deidentified')
  end

  scope :hmis, -> do
    where.not(db_identifier: 'Deidentified')
  end
end
