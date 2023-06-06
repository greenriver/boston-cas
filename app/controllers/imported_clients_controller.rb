###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ImportedClientsController < NonHmisClientsController
  before_action :require_can_manage_imported_clients!

  def new
    @upload = ImportedClientsCsv.new
  end

  def create
    unless params[:imported_clients_csv]&.[](:file)
      @upload = ImportedClientsCsv.new
      flash[:alert] = _('You must attach a file in the form.')
      render :new
      return
    end

    begin
      file = import_params[:file]
      content = file.read
      content = content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace)

      @upload = ImportedClientsCsv.create(
        filename: file.original_filename,
        user_id: current_user.id,
        content_type: file.content_type,
        content: content,
      )
      success = @upload.import(current_user.agency)
      unless success
        @upload = ImportedClientsCsv.new
        flash[:alert] = _('The file header is incorrect.')
        render :new
        return
      end
    rescue # rubocop:disable Style/RescueStandardError
      @upload = ImportedClientsCsv.new
      flash[:alert] = _('Unable to upload file, is it a CSV?')
      render :new
    end
  end

  def update
    @non_hmis_client.update(client_params)
    respond_with(@non_hmis_client, location: imported_clients_path)
  end

  def sort_options
    [
      {
        title: 'Last Name A-Z',
        column: 'last_name',
        direction: 'asc',
        order: 'LOWER(last_name) ASC',
        visible: true,
      },
      {
        title: 'Last Name Z-A',
        column: 'last_name',
        direction: 'desc',
        order: 'LOWER(last_name) DESC',
        visible: true,
      },
      {
        title: 'Days Homeless in the Last 3 Years',
        column: 'days_homeless_in_the_last_three_years',
        direction: 'desc',
        order: 'days_homeless_in_the_last_three_years DESC',
        visible: true,
      },
    ]
  end
  helper_method :sort_options

  def filter_terms
    [:family_member, :available]
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

  def import_params
    params.require(:imported_clients_csv).permit(
      :file,
    )
  end

  def assessment_type
    Config.get(:identified_client_assessment) || 'IdentifiedClientAssessment'
  end
end
