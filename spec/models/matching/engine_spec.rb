require 'rails_helper'

RSpec.describe Matching::Engine, type: :model do

  describe "engine_modes" do
    it 'contains VI-SPDAT Priority Score' do
      expect( Matching::Engine.engine_modes.keys ).to include "VI-SPDAT Priority Score"
    end
  end

end
