###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###
module Reports
  class ExternalReferralsController < ApplicationController
    before_action :authenticate_user!
    before_action :filter

    def index
      @clients = client_scope.preload(:external_referrals, :active_matches)
      index_response
    end

    def refer
      @clients = client_scope.preload(:external_referrals, :active_matches)
      ids = params[:referrals][:clients].select { |_, v| v == '1' }.keys.map(&:to_i)
      if ids.any?
        # limit download and add referral
        @clients = @clients.where(id: ids)
        referrals = ids.map do |id|
          {
            client_id: id,
            user_id: current_user.id,
            referred_on: Date.current,
          }
        end
        ExternalReferral.import(referrals)
      end
      index_response
    end

    private def index_response
      respond_to do |format|
        format.html {}
        format.xlsx do
          @dv = @clients.select(&:domestic_violence)
          @sheltered = @clients.select(&:majority_sheltered)
          @unsheltered = @clients.reject(&:majority_sheltered)

          filename = 'CAS External Referrals.xlsx'
          render xlsx: 'index.xlsx', filename: filename
        end
      end
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
        start: 1.months.ago,
        end: Date.current,
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
      ).order(assessment_score: :desc)
    end
  end
end
