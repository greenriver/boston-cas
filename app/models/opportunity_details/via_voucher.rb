module OpportunityDetails
  class ViaVoucher < Base

    delegate :voucher, to: :opportunity

    def unit_name
      voucher.unit.try :name
    end
    
    def building_name
      voucher.building.try :name
    end

    def building_address
      return [] if voucher.building.nil?
      voucher.building.building_address
    end

    def building_map_link
      return nil if voucher.building.nil?
      voucher.building.map_link
    end
    
    def program_name
      voucher.sub_program&.program&.name
    end
    
    def subgrantee_name
      voucher.building&.subgrantee&.name
    end
    
    def funding_source_name
      voucher.sub_program&.program&.funding_source&.name
    end

    def organizations
      organization_names = [funding_source_name] + voucher.sub_program&.organizations
      organization_names.compact.join(', ')
    end

    def services
      # TODO implement me
      []
    end
    
    def rules_with_source
      # TODO implement me
      []
    end
    
  end
end