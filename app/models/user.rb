class User < ActiveRecord::Base

  has_paper_trail

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :timeoutable, :confirmable
  #has_secure_password # not needed with devise

  validates :email, presence: true, uniqueness: true, email_format: { check_mx: true }, length: {maximum: 250}, on: :update
  validates :name, presence: true, length: {maximum: 40}

  scope :admin, -> {where admin: true}
  scope :dnd_staff, -> {where dnd_staff: true}
  scope :dnd_initial_contact, -> {dnd_staff.where receive_initial_notification: true}
  scope :housing_subsidy_admin, -> {where housing_subsidy_admin: true}
  
  has_one :contact, inverse_of: :user
  after_create :set_up_contact!
  accepts_nested_attributes_for :contact
  def contact_attributes= contact_attributes
    super
    self.name = contact.full_name
    self.email = contact.email
  end

  def role_keys
    [:admin, :dnd_staff, :housing_subsidy_admin]
      .select { |role| attributes[role.to_s] }
  end
  
  def roles_string
    role_keys
      .map { |role_key| role_key.to_s.humanize.gsub 'Dnd', 'DND' }
      .join(', ')
  end

  def invitation_status
    if invitation_accepted_at.present? || invitation_sent_at.blank?
      :active
    elsif invitation_due_at > Time.now
      :pending_confirmation
    else
      :invitation_expired
    end
  end

  def self.text_search(text)
    return none unless text.present?

    query = "%#{text}%"
    where(
      arel_table[:name].matches(query)
      .or(arel_table[:email].matches(query))
    )
  end
  
  private
    def set_up_contact!
      contact ||= build_contact
      contact.first_name = name.split(' ').first
      contact.last_name = name.split(' ').last
      contact.email = email
      contact.save!
    end

end
