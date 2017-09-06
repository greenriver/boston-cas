# Add a bunch a rules
namespace :rules do
  task seed: :environment do
    module Rules
      Homeless.create!(verb: 'is', name: 'Homeless')
      ChronicallyHomeless.create!(verb: 'is', name: 'Chronic Homeless')
      VeryLowIncome.create!(verb: 'has', name: 'Very Low Income (50% of Median or Less)')
      UsCitizenOrPermanentResident.create!(verb: 'is', name: 'U.S. Citizen or Permanent Resident')
      AsyleeOrRefugee.create!(verb: 'is', name: 'Asylee, Refugee')
      IneligibleImmigrant.create!(verb: 'is', name: 'Ineligible Immigrant (Including Undocumented)')
      PhysicalDisablingCondition.create!(verb: 'has', name: 'Disabling Condition: Physical')
      MentalHealthEligible.create!(verb: 'is', name: 'Mental Health Eligible')
      ChronicSubstanceUse.create!(verb: 'has', name: 'Chronic Substance Use Issues')
      MiAndSaCoMorbid.create!(verb: 'is', name: 'Co-Morbid (MI and SA)')
      MiSaOrCoMorbid.create!(verb: 'is', name: 'MI, SA or Co-Morbid')
      AidsOrRelatedDiseases.create!(verb: 'has', name: 'AIDS or Related Diseases')
      VaHealthCareEligible.create!(verb: 'is', name: 'Eligible for VA Health Care Services')
      LifetimeSexOffenderStatus.create!(verb: 'has', name: 'Life-Time Sex Offender Status')
      OnParole.create!(verb: 'is', name: 'On Parole')
      OnProbation.create!(verb: 'is', name: 'On Probation')
      MethProductionConviction.create!(verb: 'has', name: 'Meth Production Conviction')
      FederallySubsidizedHousingEvictionLastTwoYears.create!(verb: 'has', name: 'Eviction within Past 2 Years from Federally Subsidized Housing')
      ViolentCrimeConvictionLastThreeYears.create!(verb: 'has', name: 'Conviction for Violent Crime Last Three Years (including Arson)')
      ViolentCrimeConvictionLastTwoYears.create!(verb: 'has', name: 'Conviction for Violent Crime Last Two Years (including Arson)')
      UnitTerminationDueToFraudLastTenYears.create!(verb: 'has', name: 'Termination of Unit due to Fraud in Last 10 Years')
      UnitTerminationWithDamagesLastTenYears.create!(verb: 'has', name: 'Termination of Unit with Damages to Unit in Last 10 Years')
      MoneyOwedOnFederallySubsidizedUnitPaymentPlan.create!(verb: 'has', name: 'If Money Owed on Previous Federally Subsidized Unit Payment Plan In Place')
    end
  end

  task clear: :environment do
    Rule.with_deleted.map(&:really_destroy!)
  end
end
