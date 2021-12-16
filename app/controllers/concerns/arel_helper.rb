###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
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

    # Example
    # Returns most-recently started enrollment that matches the scope (open in 2020) for each client
    # GrdaWarehouse::ServiceHistoryEnrollment.entry.
    #  one_for_column(
    #   :first_date_in_program,
    #   source_arel_table: she_t,
    #   group_on: :client_id,
    #   scope: GrdaWarehouse::ServiceHistoryEnrollment.entry.open_between(
    #     start_date: '2020-01-01'.to_date,
    #     end_date: '2020-12-31'.to_date,
    #   ),
    # )
    # NOTE: group_on must all be in the same table
    def one_for_column(column, source_arel_table:, group_on:, direction: :desc, scope: nil)
      most_recent = source_arel_table.alias("most_recent_#{source_arel_table.name}_#{SecureRandom.alphanumeric}".downcase)

      if scope
        source = scope.arel
        group_table = scope.arel_table
      else
        source = source_arel_table.project(source_arel_table[:id])
        group_table = source_arel_table
      end

      direction = :desc unless direction.in?([:asc, :desc])
      group_columns = Array.wrap(group_on).map { |c| group_table[c] }

      max_by_group = source.distinct_on(group_columns).
        order(*group_columns, source_arel_table[column].send(direction))

      join = source_arel_table.create_join(
        max_by_group.as(most_recent.name),
        source_arel_table.create_on(source_arel_table[:id].eq(most_recent[:id])),
      )

      joins(join)
    end

    # Shortcuts for arel tables
    def c_t
      Client.arel_table
    end

    def pc_t
      ProjectClient.arel_table
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

    def p_t
      Program.arel_table
    end

    def sp_t
      SubProgram.arel_table
    end

    def com_t
      ClientOpportunityMatch.arel_table
    end
  end

  def c_t
    Client.arel_table
  end

  def pc_t
    ProjectClient.arel_table
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

  def p_t
    Program.arel_table
  end

  def sp_t
    SubProgram.arel_table
  end

  def com_t
    ClientOpportunityMatch.arel_table
  end
end
