class IdentifiedClient < NonHmisClient

  # Allow same search rules as Client
  scope :text_search, -> (text) do
    return none unless text.present?
    text.strip!
    sa = arel_table
    numeric = /[\d-]+/.match(text).try(:[], 0) == text
    date = /\d\d\/\d\d\/\d\d\d\d/.match(text).try(:[], 0) == text
    social = /\d\d\d-\d\d-\d\d\d\d/.match(text).try(:[], 0) == text
    # Explicitly search for only last, first if there's a comma in the search
    if text.include?(',')
      last, first = text.split(',').map(&:strip)
      if last.present?
        where = search_last_name(last).or(search_alternate_name(last))
      end
      if last.present? && first.present?
        where = where.and(search_first_name(first)).or(search_alternate_name(first))
      elsif first.present?
        where = search_first_name(first).or(search_alternate_name(first))
      end
      # Explicity search for "first last"
    elsif text.include?(' ')
      first, last = text.split(' ').map(&:strip)
      where = search_first_name(first)
          .and(search_last_name(last))
          .or(search_alternate_name(first))
          .or(search_alternate_name(last))
      # Explicitly search for a PersonalID
    elsif social
      where = sa[:ssn].eq(text.gsub('-',''))
    elsif date
      (month, day, year) = text.split('/')
      where = sa[:date_of_birth].eq("#{year}-#{month}-#{day}")
    else
      query = "%#{text}%"
      where = search_first_name(text)
          .or(search_last_name(text))
          .or(sa[:ssn].matches(query))
          .or(search_alternate_name(text))
    end
    where(where)
  end

end