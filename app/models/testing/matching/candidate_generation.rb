###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Testing::Matching::CandidateGeneration
  #@@engine_class = ::Matching::ClientOpportunityEngine

  include ActiveModel::Model

  attr_accessor :clients, :opportunities

  delegate :candidate_opportunities, to: :engine

  def engine
    @_engine = @@engine_class.new(client_scope, opportunity_scope)
  end

  def client_scope
    Client.where(id: clients)
  end

  def opportunity_scope
    Opportunity.where(id: opportunities)
  end
end
