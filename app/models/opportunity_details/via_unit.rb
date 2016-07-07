module OpportunityDetails
  class ViaUnit < Base

    delegate :unit, to: :opportunity

    def unit_name
      unit.name
    end
    
    def building_name
      unit.building.try :name
    end

    def building_address
      return [] if unit.building.nil?
      unit.building.building_address
    end
    
    def building_map_link
      return nil if voucher.building.nil?
      voucher.building.map_link
    end

    def program_name
      # unit-based opportunities don't have programs
      'N/A'
    end
    
    def subgrantee_name
      unit.building&.subgrantee&.name
    end

    def funding_source_name
      ''
    end

    def organizations
      # unit-based opportunities don't have funding sources or subgrantees
      'N/A'
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