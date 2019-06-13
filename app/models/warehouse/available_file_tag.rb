###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Warehouse
  class AvailableFileTag < Base

    scope :ordered, -> do 
      order(weight: :asc, group: :asc, name: :asc)
    end

    scope :consent_forms, -> do
      where(consent_form: true)
    end

    scope :full_release, -> do
      consent_forms.where(full_release: true)
    end

    scope :partial_consent, -> do
      consent_forms.where(full_release: false)
    end

    scope :document_ready, -> do
      where(document_ready: true)
    end

  end
end
