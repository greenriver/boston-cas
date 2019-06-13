###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class User < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  has_paper_trail

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :timeoutable, :confirmable, :pwned_password
  #has_secure_password # not needed with devise

  attr_accessor :editable_programs
  
  validates :email, presence: true, uniqueness: true, email_format: { check_mx: true }, length: {maximum: 250}, on: :update
  validates :first_name, presence: true, length: {maximum: 40}
  validates :last_name, presence: true, length: {maximum: 40}
  validates :email_schedule, inclusion: { in: Message::SCHEDULES }, allow_blank: false

  scope :admin, -> {joins(:roles).where(roles: {name: 'admin'})}
  scope :dnd_staff, -> {joins(:roles).where(roles: {can_edit_all_clients: true})}
  scope :developer, -> {joins(:roles).where(roles: {name: 'developer'})}
  scope :dnd_initial_contact, -> {dnd_staff.where receive_initial_notification: true}
  scope :housing_subsidy_admin, -> {joins(:roles).where(roles: {can_add_vacancies: true})}
  scope :active, -> {where active: true}
  scope :inactive, -> {where active: false}

  has_one :contact, inverse_of: :user

  has_many :user_roles, dependent: :destroy, inverse_of: :user
  has_many :roles, through: :user_roles
  has_many :vouchers
  has_many :messages, through: :contact

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

  def active_for_authentication?
    super && active
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

  def admin_dashboard_landing_path
    return admin_users_path if can_edit_users?
    return admin_translation_keys_path if can_edit_translations?
  end

  # allow admins to remain logged in for longer than the default
  # https://github.com/plataformatec/devise/wiki/How-To:-Add-timeout_in-value-dynamically
  def timeout_in
    return 2.hours if can_act_on_behalf_of_match_contacts?
    30.minutes
  end

  # send email upon creation or only in a periodic digest
  def continuous_email_delivery?
    email_schedule.nil? || email_schedule == 'immediate'
  end

  # does this user want to see messages in the app itself (versus only in email)
  # TODO make this depend on some attribute(s) configurable by the user and/or admins
  def in_app_messages?
    true
  end

  def can_see_non_hmis_clients?
    can_enter_deidentified_clients? || can_manage_deidentified_clients? || can_enter_identified_clients? || can_manage_identified_clients?
  end
end
