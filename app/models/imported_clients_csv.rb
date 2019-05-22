class ImportedClientsCsv < ActiveRecord::Base

  mount_uploader :file, ImportedClientsCsvFileUploader

  def import

  end
end