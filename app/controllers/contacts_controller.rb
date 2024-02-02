###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ContactsController < ApplicationController
  # Note there is a chance this could turn into an abstract base controller
  # for the things that need to manage their contacts e.g. buildings, clients,
  # etc.

  before_action :authenticate_user!
  before_action :require_can_view_contacts!
  before_action :require_can_edit_contacts!, only: [:move_matches, :update_matches]
  before_action :set_contact, only: [:move_matches, :update_matches]
  helper_method :sort_column, :sort_direction

  def index
    # search
    @contacts = if params[:q].present?
      contact_scope.text_search(params[:q])
    else
      contact_scope
    end

    # sort / paginate
    @contacts = @contacts
      .preload(:client_opportunity_match_contacts, :user)
      .order(sort_column => sort_direction)
      .page(params[:page]).per(25)

    # count number of active/closed matches per contact
    contact_ids = @contacts.map(&:id)
    @active_matches = Contact.where(id: contact_ids).
      joins(:matches).merge(ClientOpportunityMatch.active).
      group(:id).count
    @closed_matches = Contact.where(id: contact_ids).
      joins(:matches).merge(ClientOpportunityMatch.closed).
      group(:id).count
  end

  def move_matches
    @contacts = contact_scope
  end

  def update_matches
    destination = update_matches_params[:destination].to_i
    if destination.positive?
      ClientOpportunityMatchContact.
        where(contact_id: @contact.id).
        update_all(contact_id: destination)
      flash[:notice] = 'Matches updated'
    else
      ClientOpportunityMatchContact.
        where(contact_id: @contact.id).
        update_all(deleted_at: Time.current)
      flash[:notice] = 'Contact removed from all matches'
    end
    redirect_to action: :index
  end

  private def contact_source
    Contact
  end

  private def contact_scope
    Contact.all
  end

  private def set_contact
    @contact = contact_scope.find params[:id]
  end

  private def update_matches_params
    params.require(:move_contacts).permit(
      :destination,
    )
  end

  private def sort_column
    Contact.column_names.include?(params[:sort]) ? params[:sort] : 'last_name'
  end

  private def sort_direction
    ['asc', 'desc'].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  private def query_string
    "%#{@query}%"
  end
end
