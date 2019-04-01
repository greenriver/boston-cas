module MatchAccessContextsHelper
  extend ActiveSupport::Concern

  included do
    delegate :contacts_editable?, to: :access_context
  end

  def match_note_referrer_params
    {}
  end

  def access_context
    @access_context
  end

  def show_client_info?
    @match.show_client_info_to? access_context.current_contact
  end
end
