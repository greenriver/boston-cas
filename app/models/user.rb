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

  scope :admin, -> {joins(:roles).where(roles: {name: 'admin'})}
  scope :dnd_staff, -> {joins(:roles).where(roles: {name: 'dnd_staff'})}
  scope :dnd_initial_contact, -> {dnd_staff.where receive_initial_notification: true}
  scope :housing_subsidy_admin, -> {joins(:roles).where(roles: {name: 'hsa'})}
  
  has_one :contact, inverse_of: :user
  
  has_many :user_roles, dependent: :destroy, inverse_of: :user
  has_many :roles, through: :user_roles

  after_create :set_up_contact!
  accepts_nested_attributes_for :contact
  def contact_attributes= contact_attributes
    super
    self.name = contact.full_name
    self.email = contact.email
  end

  # load a hash of permission names (e.g. 'can_view_reports')
  # to a boolean true if the user has the permission through one
  # of their roles
  def load_effective_permissions
    {}.tap do |h|
      roles.each do |role|
        Role.permissions.each do |permission|
          h[permission] ||= role.send(permission)
        end
      end
    end
  end

 # define helper methods for looking up if this
 # user has an permission through one of its roles
 Role.permissions.each do |permission|
    define_method(permission) do
      @permisisons ||= load_effective_permissions
      @permisisons[permission]
    end

    define_method("#{permission}?") do
      self.send(permission)
    end
  end
  
  def roles_string
    roles
      .map { |r| r.role_name }
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
