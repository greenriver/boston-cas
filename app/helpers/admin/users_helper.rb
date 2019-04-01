module Admin
  module UsersHelper
    def user_displayable_invitation_status(user)
      case user.invitation_status
      when :confirmed then 'Active'
      when :pending_confirmation then 'Invitation Pending Confirmation.'

      end
    end
  end
end
