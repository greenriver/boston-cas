###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###
module Reports
  class ExternalReferralsController < ApplicationController
    before_action :authenticate_user!
    before_action :filter

    # TODO
    # add this as a report
    # Export selected clients
    # Optionally add Referral Event
    def index
      @clients = client_scope.preload(:external_referrals)
    end

    private def filter
      @filter ||= if params[:filter].present?
        OpenStruct.new(
          start: filter_params[:start].to_date,
          end: filter_params[:end].to_date,
          assessment_types: filter_params[:assessment_types].reject(&:blank?),
        )
      else
        default_filter
      end
    end

    private def default_filter
      OpenStruct.new(
        start: 6.months.ago,
        end: 1.days.ago,
      )
    end

    private def filter_params
      return default_filter.to_h unless params[:filter].present?

      params.require(:filter).permit(
        :start,
        :end,
        assessment_types: [],
      )
    end
    helper_method :filter_params

    private def client_scope
      @client_scope ||= Client
      return @client_scope.none if filter.assessment_types.blank?

      @client_scope.where(
        rrh_assessment_collected_at: filter.start .. filter.end,
        assessment_name: filter.assessment_types,
      )
    end
  end
end
