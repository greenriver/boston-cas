class ImportedClient < NonHmisClient
  has_one :project_client, ->  do
    where(
      data_source_id: DataSource.where(db_identifier: ImportedClient.ds_identifier).select(:id),
    )
  end, foreign_key: :id_in_data_source, required: false
  has_many :client_assessments, class_name: 'ImportedClientAssessment', foreign_key: :non_hmis_client_id, dependent: :destroy
  has_one :current_assessment, -> { order(created_at: :desc) }, class_name: 'ImportedClientAssessment', foreign_key: :non_hmis_client_id

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  def editable_by?(user)
    return true if user.can_manage_imported_clients?

    false
  end

  def populate_project_client project_client
    set_project_client_fields project_client

    if warehouse_client_id.present?
      if ! warehouse_assessment?
        project_client.save
      end
    else
      project_client.save
    end
  end

  def warehouse_assessment?
    if warehouse_project_client.present?
      # Does warehouse_project_client have the pathways tag?
      warehouse_project_client.tags.keys.include? pathways_tag_id
    else
      false
    end
  end

  def pathways_tag_id
    Tag.find_by(name: 'Pathways')&.id
  end

  def warehouse_project_client
    @warehouse_project_client ||= ProjectClient.where(data_source_id: warehouse_data_source, id_in_data_source: warehouse_client_id)
  end

  def warehouse_data_source
    DataSource.where(db_identifier: 'hmis_warehouse').pluck(:id)
  end

  def client_scope
    ImportedClient.all
  end

  def self.ds_identifier
    'Imported'
  end
end
