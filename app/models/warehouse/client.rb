module Warehouse
  class Client < Base
    self.table_name = :Client

    scope :for_client, lambda { |warehouse_client_id|
      where(id: warehouse_client_id)
    }

    scope :needs_history_pdf, lambda {
      where(generate_history_pdf: true)
    }

    def queue_history_pdf_generation
      update(generate_history_pdf: true)
    end
  end
end
