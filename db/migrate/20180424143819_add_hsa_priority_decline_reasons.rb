class AddHsaPriorityDeclineReasons < ActiveRecord::Migration
  def change
    CasSeeds::MatchDecisionReasons.new.run!
  end
end
