###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class User < ApplicationRecord
  include HasRequirements
  include Rails.application.routes.url_helpers
  include PasswordRules
  has_paper_trail

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable,
         :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :lockable,
         :timeoutable,
         :confirmable,
         :pwned_password,
         :session_limitable,
         password_length: 10..128
  # has_secure_password # not needed with devise
  # Connect users to login attempts
  has_many :login_activities, as: :user

  attr_accessor :editable_programs

  validates :email, presence: true, uniqueness: true, email_format: { check_mx: true }, length: { maximum: 250 }, on: :update
  validates :first_name, presence: true, length: { maximum: 40 }
  validates :last_name, presence: true, length: { maximum: 40 }
  validates :email_schedule, inclusion: { in: Message::SCHEDULES }, allow_blank: false
  validates :agency_id, presence: true

  scope :admin, -> { joins(:roles).where(roles: { name: 'admin' }) }
  scope :dnd_staff, -> { joins(:roles).where(roles: { can_edit_all_clients: true }) }
  scope :developer, -> { joins(:roles).where(roles: { name: 'developer' }) }
  scope :dnd_initial_contact, -> { active.dnd_staff.where receive_initial_notification: true }
  scope :housing_subsidy_admin, -> { joins(:roles).where(roles: { can_add_vacancies: true }) }
  scope :active, -> { where active: true }
  scope :inactive, -> { where active: false }
  scope :has_recent_activity, -> do
    where(id: ActivityLog.where(created_at: 30.minutes.ago..Time.current).select(:user_id)).
      where.not(unique_session_id: nil)
  end

  has_one :contact, inverse_of: :user

  has_many :user_roles, dependent: :destroy, inverse_of: :user
  has_many :roles, through: :user_roles
  has_many :vouchers
  has_many :messages, through: :contact

  belongs_to :agency

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

  def skip_session_limitable?
    ENV.fetch('SKIP_SESSION_LIMITABLE', false) == 'true'
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
      send(permission)
    end
  end

  def roles_string
    roles
      .map { |r| r.role_name } # rubocop:disable Style/SymbolProc
      .join(', ')
  end

  def invitation_status
    if invitation_accepted_at.present? || invitation_sent_at.blank?
      :active
    elsif invitation_due_at > Time.current
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
      .or(arel_table[:email].matches(query)),
    )
  end

  def admin_dashboard_landing_path
    return admin_users_path if can_edit_users?
    return admin_translation_keys_path if can_edit_translations?
  end

  def impersonateable_by?(user)
    return false unless user.present?

    user != self
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

  def self.describe_changes(_version, changes)
    changes.slice(*whitelist_for_changes_display).map do |name, values|
      "Changed #{humanize_attribute_name(name)}: from \"#{values.first}\" to \"#{values.last}\"."
    end
  end

  def self.humanize_attribute_name(name)
    name.humanize.titleize
  end

  def self.whitelist_for_changes_display
    [
      'first_name',
      'last_name',
      'email',
      'phone',
      'agency',
      'receive_file_upload_notifications',
      'notify_of_vispdat_completed',
      'notify_on_anomaly_identified',
      'receive_account_request_notifications',
    ].freeze
  end

  def can_see_non_hmis_clients?
    can_enter_deidentified_clients? || can_manage_deidentified_clients? || can_enter_identified_clients? || can_manage_identified_clients? ||
      can_manage_imported_clients?
  end

  def can_view_some_clients?
    can_view_all_clients? || can_edit_all_clients? || can_edit_clients_based_on_rules?
  end

  def inherited_requirements_by_source
    {}
  end

  def name_with_email
    "#{name} <#{email}>"
  end
end
