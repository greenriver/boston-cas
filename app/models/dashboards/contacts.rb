###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Dashboards::Contacts < Dashboards::Base
  attr_accessor :filter

  def initialize(filter)
    @filter = filter
  end

  def data
    @data = MatchRoutes::Base.active.map do |route|
      route_data(route.id)
    end
  end

  def route_data(route_id)
    data = {
      route_id: route_id,
      route: MatchRoutes::Base.active.find(route_id).title,
    }
    section_ids.each do |key|
      data[key] = reporting_scope.on_route(route_id).current_step.send(key).distinct_on(:id)
    end
    data
  end

  def column_ids
    section_ids - [:preempted, :in_progress, :unsuccessful]
  end

  def human_readable_column_name(column)
    human_readable_section_name(column)
  end

  def detail_info
    {
      match_started_at: {
        header: 'Match Start',
        transformation: :to_date,
      },
      terminal_status: {
        header: 'Terminal Status',
      },
      updated_at: {
        header: 'Date of Status',
        transformation: :to_date,
      },
      program_name: {
        header: 'Program Name',
      },
      sub_program_name: {
        header: 'Sub Program Name',
      },
    }
  end

  def format_datum(key, datum)
    formatter = detail_info[key][:transformation]
    return datum unless formatter.present?

    datum.send(formatter)
  end

  def detail_headers
    detail_info.values.map { |v| v[:header] }
  end

  def detail_columns
    detail_info.keys
  end

  private def reporting_scope
    scope = Reporting::Decisions
    @filter.apply(scope)
  end
end
