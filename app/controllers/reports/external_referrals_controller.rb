###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
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
        format.html do
          # paginate, but attempt to get all clients on one page because we may be adding a referral,
          # which won't work right if we're exporting a huge number all at once.
          @clients = @clients.page(params[:page]).per(250)
        end
        format.xlsx do
          @clients = @clients.preload(:external_referrals, :active_matches, :project_client).to_a
          @dv = @clients.select { |c| c.domestic_violence == 1 }.map(&:id).to_set
          @sheltered = @clients.select(&:majority_sheltered).map(&:id).to_set
          @unsheltered = @clients.reject(&:majority_sheltered).map(&:id).to_set
          # Get a hash of assessments that we can use for generating columns, we only need one per assessment type, ignore the differences between
          # de-identified and identified
          @assessment_classes = {}
          @clients.each do |client|
            assessment = NonHmisAssessment.to_class(client.assessment_name)
            title = NonHmisAssessment.declassify_title(NonHmisAssessment.title_from_type_for_matching(client.assessment_name))
            @assessment_classes[title] ||= assessment
          end

          @clients = @clients.group_by { |c| NonHmisAssessment.declassify_title(NonHmisAssessment.known_assessments_for_matching[c.assessment_name]) }

          filename = 'CAS External Referrals.xlsx'
          render xlsx: 'index', filename: filename
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
        rrh_assessment_collected_at: filter.start .. filter.end.end_of_day,
        assessment_name: filter.assessment_types,
      ).where.not(last_name: ['Test', 'Fake']). # Specifically requested to avoid sending test clients externally
        order(assessment_score: :desc, tie_breaker_date: :asc)
    end
  end
end
