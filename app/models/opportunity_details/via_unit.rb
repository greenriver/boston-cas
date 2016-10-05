module OpportunityDetails
  class ViaUnit < Base

    delegate :unit, to: :opportunity
    delegate :sub_program, to: :voucher

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
      sub_program&.program&.name
    end

    def sub_program_name
      sub_program&.name
    end
    
    def subgrantee_name
      unit.building&.subgrantee&.name
    end

    def funding_source_name
      sub_program&.program&.funding_source&.name
    end

    # build a hash of associated bits to store at match creation
    def opportunity_for_archive
      {
        opportunity: prepare_for_archive,
        voucher: voucher.try(:prepare_for_archive),
        sub_program: voucher.sub_program.try(:prepare_for_archive),
        program: voucher.sub_program.program.try(:prepare_for_archive),
        subgrantee: voucher.sub_program.sub_contractor.try(:prepare_for_archive),
        sub_contractor: voucher.sub_program.service_provider.try(:prepare_for_archive),
        funding_source: voucher.sub_program.program.funding_source.try(:prepare_for_archive),
        unit: unit.try(:prepare_for_archive),
        building: unit.building.try(:prepare_for_archive),
      }
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