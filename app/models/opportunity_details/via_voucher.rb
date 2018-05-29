module OpportunityDetails
  class ViaVoucher < Base

    delegate :voucher, to: :opportunity
    delegate :sub_program, to: :voucher

    def unit_name
      voucher.unit.try :name
    end

    def unit_on_ground_floor?
      return nil unless voucher.unit
      voucher.unit.ground_floor? ? "Yes" : "No"
    end

    def unit_is_wheelchair_accessible?
      return nil unless voucher.unit
      voucher.unit.wheelchair_accessible? ? "Yes" : "No"
    end

    def unit_occupancy
      return nil unless voucher.unit
      voucher.unit.occupancy
    end

    def unit_bedrooms
      return nil unless voucher.unit
      voucher.unit.number_of_bedrooms
    end

    def unit_target_population
      return nil unless voucher.unit
      voucher.unit.target_population.titleize
    end

    def unit_details
      return nil unless voucher.unit
      [
        "Ground Floor: #{unit_on_ground_floor?}",
        "Wheelchair Accessible: #{unit_is_wheelchair_accessible?}",
        "Occupancy: #{unit_occupancy}",
        "Bedrooms: #{unit_bedrooms}",
        "Target Population: #{unit_target_population}",
      ]
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

    def sub_program_name
      voucher.sub_program&.name
    end

    def service_provider_name
      voucher.sub_program&.service_provider&.name
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
        voucher: voucher.try(:prepare_for_archive),
        sub_program: voucher.sub_program.try(:prepare_for_archive),
        program: voucher.sub_program.program.try(:prepare_for_archive),
        subgrantee: voucher.sub_program.sub_contractor.try(:prepare_for_archive),
        sub_contractor: voucher.sub_program.service_provider.try(:prepare_for_archive),
        funding_source: voucher.sub_program.program.funding_source.try(:prepare_for_archive),
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
