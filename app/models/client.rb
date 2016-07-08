class Client < ActiveRecord::Base

  include SubjectForMatches

  has_paper_trail
  acts_as_paranoid

  belongs_to :ethnicity, foreign_key: :ethnicity_id, primary_key: :numeric
  belongs_to :race, foreign_key: :race_id, primary_key: :numeric
  belongs_to :veteran_status, foreign_key: :veteran_status_id, primary_key: :numeric
  belongs_to :gender, foreign_key: :gender_id, primary_key: :numeric

  has_one :project_client, primary_key: :id, foreign_key: :client_id
  has_many :building_clients

  # all contacts
  has_many :client_contacts, dependent: :destroy, inverse_of: :client
  has_many :contacts, through: :client_contacts

  has_many :regular_client_contacts, -> { where regular: true},
    class_name: 'ClientContact'
  has_many :regular_contacts,
    through: :regular_client_contacts,
    source: :contact

  has_many :shelter_agency_client_contacts, -> { where shelter_agency: true},
    class_name: 'ClientContact'
  has_many :shelter_agency_contacts,
    through: :shelter_agency_client_contacts,
    source: :contact

  validates :ssn, length: {maximum: 9}



  def full_name
    [first_name, middle_name, last_name, name_suffix].select{|n| n.present?}.join(' ')
  end
  alias_method :name, :full_name

  def self.text_search(text)
    return none unless text.present?
    query = "%#{text}%"
    where(
      arel_table[:first_name].matches(query)
      .or(arel_table[:last_name].matches(query))
      .or(arel_table[:middle_name].matches(query))
      .or(arel_table[:ssn].matches(query))
    )
  end

  def self.prioritized
    order(:calculated_first_homeless_night)
  end

  def self.max_candidate_matches
    4
  end

  def self.randomize_pii
    all.each do |c|
      c.first_name = Faker::Name.first_name
      c.middle_name = Faker::Boolean.boolean(0.10) ? Faker::Name.last_name : nil
      c.last_name = Faker::Name.last_name
      c.name_suffix = ''
      c.ssn = Faker::Number.number(9)
      c.date_of_birth = Faker::Date.between(80.years.ago, 25.years.ago)
      c.homephone = Faker::Boolean.boolean(0.5) ? Faker::PhoneNumber.cell_phone : nil
      c.cellphone = Faker::Boolean.boolean(0.5) ? Faker::PhoneNumber.cell_phone : nil
      c.workphone = Faker::Boolean.boolean(0.5) ? Faker::PhoneNumber.cell_phone : nil
      c.pager = ''
      c.email = ''
      c.save(validate: false)
    end
  end

  def self.accessible_by_user(user)
    if user.admin? || user.dnd_staff?
      all
    else
      none
    end
  end

  def accessible_by_user?(user)
    if user.admin? || user.dnd_staff?
      true
    else
      false
    end
  end

  def merged_with_name
    c = Client.find(merged_into)
    c.full_name
  end

  def previously_merged?
    count = Client.where(merged_into: id).pluck(id).length
    if count > 0
      return true
    end
    return false
  end

  def age
    if date_of_birth.present?
      Date.today.year - date_of_birth.to_date.year
    end
  end

  def prioritized_matches
    client_opportunity_matches.joins(:opportunity).order('opportunities.matchability asc')
  end

  def housing_history
    #client_opportunity_matches.inspect
  end
end
