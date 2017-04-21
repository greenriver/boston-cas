class User < ActiveRecord::Base

  has_paper_trail

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :timeoutable, :confirmable
  #has_secure_password # not needed with devise

  validates :email, presence: true, uniqueness: true, email_format: { check_mx: true }, length: {maximum: 250}, on: :update
  validates :first_name, presence: true, length: {maximum: 40}
  validates :last_name, presence: true, length: {maximum: 40}

  scope :admin, -> {joins(:roles).where(roles: {name: 'admin'})}
  scope :dnd_staff, -> {joins(:roles).where(roles: {name: 'dnd_staff'})}
  scope :developer, -> {joins(:roles).where(roles: {name: 'developer'})}
  scope :dnd_initial_contact, -> {dnd_staff.where receive_initial_notification: true}
  scope :housing_subsidy_admin, -> {joins(:roles).where(roles: {name: 'hsa'})}
  
  has_one :contact, inverse_of: :user
  
  has_many :user_roles, dependent: :destroy, inverse_of: :user
  has_many :roles, through: :user_roles
  has_many :vouchers

  accepts_nested_attributes_for :contact
  def contact_attributes= contact_attributes
    super
    self.first_name = contact.first_name
    self.last_name = contact.last_name
    self.email = contact.email
  end

  def self.non_admin
    User.where.not(id: User.admin.select(:id)).
      where.not(id: User.developer.select(:id))
  end

  def name
    "#{first_name} #{last_name}"
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
      arel_table[:first_name].matches(query)
      .or(arel_table[:last_name].matches(query))
      .or(arel_table[:email].matches(query))
    )
  end

  # allow admins to remain logged in for longer than the default
  # https://github.com/plataformatec/devise/wiki/How-To:-Add-timeout_in-value-dynamically
  def timeout_in
    return 2.hours if can_act_on_behalf_of_match_contacts?
    30.minutes
  end
end
