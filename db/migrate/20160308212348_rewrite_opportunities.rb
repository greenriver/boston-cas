class RewriteOpportunities < ActiveRecord::Migration[4.2]
  def change
      rename_column :opportunities, :opportunity_type, :type # voucher or housing
      add_column :opportunities, :geo_code, :string
      add_column :opportunities, :target_population_a, :string
      add_column :opportunities, :target_population_b, :string
      add_column :opportunities, :mc_kinney_vento, :boolean

      # See 2.7B in https://www.hudexchange.info/resources/documents/Notice-CPD-15-010-2016-HIC-PIT-Data-Collection-Notice.pdf
      add_column :opportunities, :chronic, :integer
      add_column :opportunities, :veteran, :integer
      add_column :opportunities, :adult_only, :integer
      add_column :opportunities, :family, :integer
      add_column :opportunities, :child_only, :integer

  end
end
