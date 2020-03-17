###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

# provides less verbose versions of stuff that's useful for working with arel
# these are all two letters both for maximum brevity and because this makes them more includable -- they are unlikely to be stomped on by other methods or functions
module ArelHelper
  extend ActiveSupport::Concern

  # give these methods to instances
  included do
    def qt(value)
      self.class.qt value
    end

    def nf(*args)
      self.class.nf(*args)
    end
  end

  # and to the class itself (so they can be used in scopes, for example)
  class_methods do
    # convert non-node into a node
    def qt(value)
      case value
      when Arel::Attributes::Attribute, Arel::Nodes::Node, Arel::Nodes::Quoted
        value
      else
        Arel::Nodes::Quoted.new value
      end
    end

    # create a named function
    #   nf 'NAME', [ arg1, arg2, arg3 ], 'alias'
    def nf(name, args = [], aka = nil)
      raise 'args must be an Array' unless args.is_a?(Array)

      Arel::Nodes::NamedFunction.new name, args.map { |v| qt v }, aka
    end

    # Shortcuts for arel tables
    def c_t
      Client.arel_table
    end

    def o_t
      Opportunity.arel_table
    end

    def r_d_t
      Reporting::Decisions.arel_table
    end

    def md_b_t
      MatchDecisions::Base.arel_table
    end

    def v_t
      Voucher.arel_table
    end

    def uacf_t
      UnavailableAsCandidateFor.arel_table
    end

    def mdr_b_t
      MatchDecisionReasons::Base.arel_table
    end
  end

  def c_t
    Client.arel_table
  end

  def o_t
    Opportunity.arel_table
  end

  def r_d_t
    Reporting::Decisions.arel_table
  end

  def md_b_t
    MatchDecisions::Base.arel_table
  end

  def v_t
    Voucher.arel_table
  end

  def uacf_t
    UnavailableAsCandidateFor.arel_table
  end

  def mdr_b_t
    MatchDecisionReasons::Base.arel_table
  end
end