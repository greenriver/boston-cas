###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
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

    def cl(*args)
      self.class.cl(*args)
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

    def cl(*args)
      nf('COALESCE', args)
    end

    # Example
    # Returns most-recently created non-HMIS assessment for each non-HMIS client
    # NonHmisAssessment.one_for_column(
    #   order_clause: NonHmisAssessment.arel_table[:created_at].desc,
    #   source_arel_table: NonHmisAssessment.arel_table,
    #   group_on: :non_hmis_client_id,
    #   scope: NonHmisAssessment.where(non_hmis_client_id: client_ids),
    # )
    # NOTE: group_on must all be in the same table
    def one_for_column(order_clause:, source_arel_table:, group_on:, scope: nil)
      most_recent = source_arel_table.alias("most_recent_#{source_arel_table.name}_#{SecureRandom.alphanumeric}".downcase)

      if scope
        source = scope.arel
        group_table = scope.arel_table
      else
        source = source_arel_table.project(source_arel_table[:id])
        group_table = source_arel_table
      end

      group_columns = Array.wrap(group_on).map { |c| group_table[c] }
      max_by_group = source.distinct_on(group_columns).
        order(*group_columns, order_clause)

      join = source_arel_table.create_join(
        max_by_group.as(most_recent.name),
        source_arel_table.create_on(source_arel_table[:id].eq(most_recent[:id])),
      )

      joins(join)
    end

    def age_on_date(start_date = Date.current)
      cast(
        datepart(
          'YEAR',
          nf('AGE', [start_date, c_t[:date_of_birth]]),
        ),
        'integer',
      )
    end

    def datepart(type, date)
      date = lit "#{Arel::Nodes::Quoted.new(date).to_sql}::date" if date.is_a? String
      nf('DATE_PART', [type, date])
    end

    def cast(exp, as)
      exp = qt(exp)
      exp = lit(exp.to_sql) unless exp.respond_to?(:as)
      nf('CAST', [exp.as(as)])
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

    def me_b_t
      MatchEvents::Base.arel_table
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

    def tag_t
      Warehouse::Tag.arel_table
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

  def me_b_t
    MatchEvents::Base.arel_table
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

  def tag_t
    Warehouse::Tag.arel_table
  end

  def com_t
    ClientOpportunityMatch.arel_table
  end
end
