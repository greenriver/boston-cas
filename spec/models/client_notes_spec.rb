require 'rails_helper'

RSpec.describe ClientNote, type: :model do

  let(:client_note) { create :client_note}
  
  describe 'validations' do 
     
    context 'if note present' do
      let(:client_note) { build :client_note, note: "This is a note" }
       
      it 'is valid' do
        expect( client_note ).to be_valid
      end 
    end
    
    context 'if note missing' do
      let(:client_note) { build :client_note, note: nil }
       
      it 'is invalid' do
        expect( client_note ).to be_invalid
      end 
    end
 end
 
 describe 'associations' do   
   it { should belong_to( :user ) }
   it { should belong_to( :client ) }
 end
 
 describe 'instance methods' do
    describe 'user_can_destroy?(user)' do
      let(:admin_role) { create :admin_role, can_delete_client_notes: true }
      let(:shelter_role) { create :shelter_role, can_delete_client_notes: false }
        
      let(:bob) { create :user }
      let(:sally) { create :user }
      let(:arnold) { create :user }

      let(:client_note_written_by_bob) { create :client_note, user: bob }
      
      before do
        bob.roles << shelter_role
        sally.roles << shelter_role
        arnold.roles << admin_role 
      end
      
      context 'if user is note author but does not have permission to delete all notes' do
        it 'user can destroy note' do 
          expect( client_note_written_by_bob.user_can_destroy?( bob ) ).to eq true
        end
      end
    
      context 'if user is not note author and does not have permission to delete all notes' do
        it 'user cannot destroy note' do
          expect( client_note_written_by_bob.user_can_destroy?( sally ) ).to eq false
        end
      end
      
      context 'if user is not note author but DOES have permission to delete all notes' do
        it 'user can destroy note' do
          expect( client_note_written_by_bob.user_can_destroy?( arnold ) ).to eq true
        end
      end
    end
  end
end
