###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchListBaseHelper

  def search_directions
    columns = ['created_at']
    @_search_directions ||= current_sort_order Hash[columns.map {|x| [x, nil]}]
  end

  def show_match_status_facet_nav?
    current_user.can_view_all_matches? || current_user.can_view_own_closed_matches?
  end

  def show_links_to_matches?
    true
  end

end
