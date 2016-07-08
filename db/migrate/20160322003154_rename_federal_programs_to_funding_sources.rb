class RenameFederalProgramsToFundingSources < ActiveRecord::Migration
  def change
    rename_table :federal_programs, :funding_sources
  end
end
