###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

# frozen_string_literal: true

class ImportedClientsController < NonHmisClientsController
  before_action :require_can_manage_imported_clients!

  private def search_path
    imported_client_search_query_path(@search_query)
  end

  private def non_hmis_client_index_path
    imported_clients_path
  end

  def new
    @upload = ImportedClientsCsv.new
  end

  def create
    unless params[:imported_clients_csv]&.[](:file)
      @upload = ImportedClientsCsv.new
      flash[:alert] = Translation.translate('You must attach a file in the form.')
      render :new
      return
    end

    begin
      file = import_params[:file]
      file_content = file.read
      file_content = file_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace)

      # Validate file content before creating record
      validation_result = ImportedClientsCsv.validate_file_content(file_content, file.content_type)

      unless validation_result[:valid]
        @upload = ImportedClientsCsv.new
        flash[:alert] = validation_result[:error]
        render :new
        return
      end

      # File is valid, now create the record
      @upload = ImportedClientsCsv.create(
        filename: file.original_filename,
        user_id: current_user.id,
        content_type: validation_result[:detected_type], # Use the real detected type
        content: file_content,
      )

      success = @upload.import(current_user.agency)
      unless success
        @upload = ImportedClientsCsv.new
        flash[:alert] = Translation.translate('The file header is incorrect.')
        render :new
        return
      end
    rescue Exception => e
      @upload = ImportedClientsCsv.new
      flash[:alert] = Translation.translate('Unable to upload file, is it a CSV?')
      Sentry.capture_exception(e)
      render :new
    end
  end

  def update
    @non_hmis_client.update(client_params)
    respond_with(@non_hmis_client, location: imported_clients_path)
  end

  def non_hmis_client_search_queries_path
    imported_client_search_queries_path
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

  def sorter
    @column = params[:sort]
    @direction = params[:direction]
    default_sort = sort_options.first.try(:[], :order)

    sort_string = if @column.blank?
      @column = sort_options.first.try(:[], :column)
      @direction = sort_options.first.try(:[], :direction)
      default_sort
    else
      sort_options.select do |m|
        m[:column] == @column && m[:direction] == @direction
      end.try(:first).try(:[], :order) || default_sort
    end
    sort_string += ' NULLS LAST' if ApplicationRecord.connection.adapter_name == 'PostgreSQL'
    sort_string
  end

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
