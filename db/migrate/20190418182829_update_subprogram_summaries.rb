class UpdateSubprogramSummaries < ActiveRecord::Migration
  def change
    SubProgram.all.each {|s| s.update_summary!}
  end
end
