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
      }
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