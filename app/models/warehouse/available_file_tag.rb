module Warehouse
  class AvailableFileTag < Base
    scope :ordered, lambda {
      order(weight: :asc, group: :asc, name: :asc)
    }

    scope :consent_forms, lambda {
      where(consent_form: true)
    }

    scope :full_release, lambda {
      consent_forms.where(full_release: true)
    }

    scope :partial_consent, lambda {
      consent_forms.where(full_release: false)
    }

    scope :document_ready, lambda {
      where(document_ready: true)
    }
  end
end
