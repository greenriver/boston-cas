class SetEventForCeEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_programs, :event, :integer
    SubProgram.find_each do |sp|
      sp.event = case sp.match_route&.class&.name
      when 'MatchRoutes::Four'
        14 # PSH
      when 'MatchRoutes::Default'
        14 # PSH
      when 'MatchRoutes::HomelessSetAside'
        15 # PH
      when 'MatchRoutes::ProviderOnly'
        13 # RRH
      when 'MatchRoutes::Five'
        13 # RRH
      else
        14 # default to PSH referral
      end
      sp.save
    end
  end
end
