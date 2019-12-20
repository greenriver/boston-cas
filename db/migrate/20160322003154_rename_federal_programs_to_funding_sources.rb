class RenameFederalProgramsToFundingSources < ActiveRecord::Migration[4.2]
  def change
    rename_table :federal_programs, :funding_sources
  end
end
