class UserFactory

  def initialize
    @_users = {}
  end

  def admin
    @_users[:admin] ||= User.where(email: 'admin@test.com').first_or_create! do |user|
      user.name = 'Admin Test User'
      user.admin = true
      set_common_user_attrs(user)
    end
  end

  def dnd_staff
    @_users[:dnd_staff] ||= User.where(email: 'dnd_staff@test.com').first_or_create! do |user|
      user.name = 'DND Staff Test User'
      user.dnd_staff = true
      set_common_user_attrs(user)
    end
  end

  def hsa_admin
    @_users[:hsa_admin] ||= User.where(email: 'hsa_admin@test.com').first_or_create! do |user|
      user.name = 'Housing Subsidy Administrator Test User'
      user.housing_subsidy_admin = true
      set_common_user_attrs(user)
    end
  end

  def unprivileged_user
    @_users[:unprivileged_user] ||= User.where(email: 'unprivileged_user@test.com').first_or_create! do |user|
      user.name = 'Unprivileged Test User'
      set_common_user_attrs(user)
    end
  end

  private def set_common_user_attrs user
    user.confirmed_at = Time.now
    user.password = 'testtest'
    user.password_confirmation = 'testtest'
  end
  


end