class DeidentifiedClient < NonHmisClient
  validates :client_identifier, uniqueness: true

  # Search only the client identifier
  scope :text_search, -> (text) do
    return none unless text.present?
    text.strip!
    where(search_alternate_name(text))
  end

end
