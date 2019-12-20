class UpdateSubprogramSummaries < ActiveRecord::Migration[4.2]
  def change
    SubProgram.all.each {|s| s.update_summary!}
  end
end
