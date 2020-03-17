###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Reporting::Decisions < ApplicationRecord
  scope :started_between, -> (start_date:, end_date:) do
    where(match_started_at: (start_date..end_date))
  end

  scope :ended_between, -> (start_date:, end_date:) do
    terminated.
    where(updated_at: (start_date..end_date + 1.day))
  end

  scope :current_step, -> do
    where(current_step: true)
  end

  scope :in_progress, -> do
    where(terminal_status: 'In Progress')
  end

  scope :terminated, -> do
    where.not(terminal_status: 'In Progress')
  end

  scope :success, -> do
    where(terminal_status: 'Success')
  end

  scope :preempted, -> do
    where(terminal_status: 'Pre-empted')
  end

  scope :rejected, -> do
    where(terminal_status: 'Rejected')
  end
end