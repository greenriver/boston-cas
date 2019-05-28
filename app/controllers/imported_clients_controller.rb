class ImportedClientsController < NonHmisClientsController
  before_action :require_can_manage_imported_clients!

  def update
    @non_hmis_client.update(client_params)
    respond_with(@non_hmis_client, location: imported_clients_path)
  end

  def sort_options
    [
      {title: 'Last Name A-Z', column: 'last_name', direction: 'asc', order: 'LOWER(last_name) ASC', visible: true},
      {title: 'Last Name Z-A', column: 'last_name', direction: 'desc', order: 'LOWER(last_name) DESC', visible: true},
      {title: 'Days Homeless in the Last 3 Years', column: 'days_homeless_in_the_last_three_years', direction: 'desc',
        order: 'days_homeless_in_the_last_three_years DESC', visible: true},
    ]
  end
  helper_method :sort_options

  def filter_terms
    [ :family_member, :available ]
  end
  helper_method :filter_terms

  def client_source
    ImportedClient.identified.visible_to(current_user)
  end

  def client_params
    params.require(:imported_client).permit(
      :warehouse_client_id,
      :available,
    )
  end
end