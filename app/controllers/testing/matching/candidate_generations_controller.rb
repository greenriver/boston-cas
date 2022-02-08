###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Testing::Matching
  class CandidateGenerationsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_can_edit_all_clients!

    # actions

    def new
      @candidate_generation = CandidateGeneration.new
    end

    def create
      @candidate_generation = CandidateGeneration.new(submitted_params)
    end

    # other stuff

    def submitted_params
      params.
        require(:testing_matching_candidate_generation).
        permit({clients: [], opportunities: []})
    end

    helper_method :multi

    def multi(form, attribute, collection)
      form.input attribute, collection: collection, input_html: {multiple: true}
    end
  end
end
