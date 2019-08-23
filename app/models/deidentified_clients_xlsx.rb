class DeidentifiedClientsXlsx < ActiveRecord::Base

  mount_uploader :file, DeidentifiedClientsXlsxFileUploader

end