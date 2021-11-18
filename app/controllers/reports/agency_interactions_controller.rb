###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/production/LICENSE.md
###

module Reports
  class AgencyInteractionsController < ApplicationController
    include ArelHelper

    before_action :authenticate_user!
    before_action :filter
    before_action :matches

    def index
      respond_to do |format|
        format.html do
          @matches = @matches.page(params[:page].to_i).per(25)
        end
        format.xlsx do
          filename = 'Agency Interactions.xlsx'
          render xlsx: 'index.xlsx', filename: filename
        end
      end
    end

    def match_decision_reasons_collection
      MatchDecisionReasons::Base.
        order(name: :asc).
        map { |reason| [reason_text(reason), reason.id] }
    end
    helper_method :match_decision_reasons_collection

    def reason_text(match_decision_reason)
      text = match_decision_reason.name
      text << " (#{match_decision_reason.title})" if match_decision_reason.title.present?
      text
    end
    helper_method :reason_text

    def format_contacts(contacts)
      contacts.map { |contact| "#{contact.name} (#{contact.email})" }.join(', ')
    end
    helper_method :format_contacts

    private def matches
      @matches ||= begin
        candidates = ClientOpportunityMatch.
          unsuccessful.
          where(updated_at: @filter.start..@filter.end).
          joins(:decisions, :client).
          visible_by(current_user)

        candidates.where(md_b_t[:decline_reason_id].in(@filter[:reasons])).
          or(candidates.where(md_b_t[:administrative_cancel_reason_id].in(@filter[:reasons]))).
          order(decline_reason_id: :asc, administrative_cancel_reason_id: :asc)
      end
    end

    private def filter
      @filter ||= if params[:filter].present?
        OpenStruct.new(start: filter_params[:start].to_date, end: filter_params[:end].to_date, reasons: filter_params[:reasons].map(&:to_i))
      else
        default_filter
      end
    end

    private def default_filter
      OpenStruct.new(start: 6.months.ago, end: 1.days.ago, reasons: [])
    end

    private def filter_params
      return default_filter.to_h unless params[:filter].present?

      params.require(:filter).permit(
        :start,
        :end,
        reasons: [],
      )
    end
    helper_method :filter_params
  end
end
