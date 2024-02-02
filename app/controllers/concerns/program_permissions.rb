###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module ProgramPermissions
  extend ActiveSupport::Concern

  included do
    private def program_scope
      if can_view_programs?
        return Program.all
      elsif can_view_assigned_programs?
        return Program.visible_by(current_user)
      else
        not_authorized!
        return Program.none
      end
    end

    private def sub_program_scope
      if can_view_programs?
        return SubProgram.all
      elsif can_view_assigned_programs?
        return SubProgram.visible_by(current_user)
      else
        not_authorized!
        return Program.none
      end
    end

    private def check_edit_permission!
      not_authorized! unless can_edit_programs? || (can_edit_assigned_programs? && @subprogram&.editable_by?(current_user))
    end

  end
end
