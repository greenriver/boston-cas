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

    # build a hash of associated bits to store at match creation
    def opportunity_for_archive
      {
        opportunity: prepare_for_archive,
        voucher: voucher.prepare_for_archive,
        sub_program: voucher.sub_program.prepare_for_archive,
        program: voucher.sub_program.program.prepare_for_archive,
        subgrantee: voucher.sub_program.sub_contractor.prepare_for_archive,
        sub_contractor: voucher.sub_program.service_provider.prepare_for_archive,
        funding_source: voucher.sub_program.program.funding_source.prepare_for_archive,
        unit: unit.prepare_for_arvive,
        building: unit.building.prepare_for_arvive,
      }
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