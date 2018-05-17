require 'rails_helper'

RSpec.describe ClientNotesController, type: :controller do
  let!( :admin ) { create :user }
  let!( :admin_role ) { create :admin_role }
  let!( :client_note ) { create :client_note }
  let!( :initial_note_count ) { ClientNote.count }
  let!( :client ) { create :client }

  before do
    authenticate admin
    admin.roles << admin_role
  end
  
  describe 'DELETE #destroy' do

    it 'deletes the note' do 
      expect{ delete :destroy, id: client_note, client_id: client_note.client_id }.to change( ClientNote, :count ).by( -1 )
    end
    
    it 'redirects to Client/#show' do
      delete :destroy, id: client_note, client_id: client_note.client_id
      expect( response ).to redirect_to( client_path(client_note.client_id ))
    end
  end

  describe "POST #create_note" do
    context "with valid attributes" do
      before do
        post :create, client_note: attributes_for(:client_note), client_id: client.id 
      end
      
      it "creates client note" do
        expect(ClientNote.count).to eq(initial_note_count + 1)
      end
      
      it "redirects to Client#show" do
        expect( response ).to redirect_to(client_path(client.id))
      end
    end
    
    context "with invalid attributes" do
      before { post :create, client_note: { :note=>"" }, client_id: client.id } #invalid because note is an empty string
      
      it "does not save the new contact" do   
        expect(ClientNote.count).to eq(initial_note_count)
      end
    
      it "re-renders Client#show" do
        expect( response ).to redirect_to(client_path(client.id))
      end
    end
  end
end
