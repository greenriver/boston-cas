module MatchListBaseHelper

  def search_directions
    columns = ['created_at']
    @_search_directions ||= current_sort_order Hash[columns.map {|x| [x, nil]}]
  end
  
  def show_match_status_facet_nav?
    current_user.admin? || current_user.dnd_staff?
  end

  def show_links_to_matches?
    true
  end

end