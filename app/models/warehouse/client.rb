module Warehouse
  class Client < Base
    self.table_name = :Client

    scope :for_client, -> (warehouse_client_id) do
      where(id: warehouse_client_id)
    end

    scope :needs_history_pdf, -> do
      where(generate_history_pdf: true)
    end

    def queue_history_pdf_generation
      update(generate_history_pdf: true)
    end
  end
end