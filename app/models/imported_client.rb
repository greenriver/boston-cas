class ImportedClient < NonHmisClient
  has_one :project_client, ->  do
    where(
      data_source_id: DataSource.where(db_identifier: ImportedClient.ds_identifier).select(:id),
    )
  end, foreign_key: :id_in_data_source, required: false

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :set_asides_housing_status, presence: true
  validates :days_homeless_in_the_last_three_years, presence: true, numericality: { less_than_or_equal_to: 1096 }
  validates :shelter_name, presence: true
  validates :entry_date, presence: true
  validates :phone_number, presence: true
  # validates :income_total_monthly, presence: true, numericality: true
  validates :voucher_agency, presence: true, if: :have_tenant_voucher?

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
