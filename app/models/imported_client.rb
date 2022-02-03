###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ImportedClient < NonHmisClient
  has_one :project_client, -> do
    where(
      data_source_id: DataSource.where(db_identifier: ImportedClient.ds_identifier).select(:id),
    )
  end, foreign_key: :id_in_data_source, required: false
  has_many :client_assessments, class_name: 'ImportedClientAssessment', foreign_key: :non_hmis_client_id, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  # Allow same search rules as Client
  scope :text_search, -> (text) do
    return none unless text.present?
    text.strip!
    sa = arel_table
    numeric = /[\d-]+/.match(text).try(:[], 0) == text
    date = /\d\d\/\d\d\/\d\d\d\d/.match(text).try(:[], 0) == text
    social = /\d\d\d-\d\d-\d\d\d\d/.match(text).try(:[], 0) == text
    # Explicitly search for only last, first if there's a comma in the search
    if text.include?(',')
      last, first = text.split(',').map(&:strip)
      if last.present?
        where = search_last_name(last).or(search_alternate_name(last))
      end
      if last.present? && first.present?
        where = where.and(search_first_name(first)).or(search_alternate_name(first))
      elsif first.present?
        where = search_first_name(first).or(search_alternate_name(first))
      end
      # Explicity search for "first last"
    elsif text.include?(' ')
      first, last = text.split(' ').map(&:strip)
      where = search_first_name(first)
          .and(search_last_name(last))
          .or(search_alternate_name(first))
          .or(search_alternate_name(last))
      # Explicitly search for a PersonalID
    elsif social
      where = sa[:ssn].eq(text.gsub('-', ''))
    elsif date
      (month, day, year) = text.split('/')
      where = sa[:date_of_birth].eq("#{year}-#{month}-#{day}")
    else
      query = "%#{text}%"
      where = search_first_name(text).
        or(search_last_name(text)).
        or(sa[:ssn].matches(query)).
        or(search_alternate_name(text))
    end
    where(where)
  end

  def editable_by?(user)
    return true if user.can_manage_imported_clients?

    false
  end

  def current_assessment
    @current_assessment ||= NonHmisAssessment.where(non_hmis_client_id: id).order(created_at: :desc).first || client_assessments.build
  end

  def self.current_assessments_for(client_ids)
    a_t = NonHmisAssessment.arel_table
    NonHmisAssessment.one_for_column(
      order_clause: a_t[:created_at].desc,
      source_arel_table: NonHmisAssessment.arel_table,
      group_on: :non_hmis_client_id,
      scope: NonHmisAssessment.where(non_hmis_client_id: client_ids),
    ).index_by(&:non_hmis_client_id)
  end

  def populate_project_client(project_client)
    project_client = set_project_client_fields(project_client)
    return project_client unless warehouse_client_id.present?
    return project_client unless warehouse_assessment?

    nil
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
