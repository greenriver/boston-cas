require 'rails_helper'

RSpec.describe MatchEvents::Note, type: :model do

  let(:shelter) { create :user }
  let(:admin) { create :user_two }
  let(:no_roles) { create :user_three }
  let(:admin_role) {create :admin_role }
  let(:shelter_role) {create :shelter_role }
  let(:match) { create :client_opportunity_match }
  let(:admin_note) { create :admin_note }
  let(:match_note) { create :match_note }

  describe 'Note access: ' do
    before do
      admin.roles << admin_role
      match.dnd_staff_contacts << admin.contact
      match.shelter_agency_contacts << shelter.contact
      match.client_contacts << no_roles.contact
      admin_note.match = match
      admin_note.contact = admin.contact
      match_note.match = match
      match_note.contact = admin.contact
    end
    context 'If admin creates the note,' do
      it 'admin should be able to edit it' do
        expect( match_note.note_editable_by?(admin.contact) ).to be(true)
      end
      it 'shelter should not be able to edit it' do
        expect( match_note.note_editable_by?(shelter.contact) ).to be_falsy
      end
      it 'admin should be able to edit administrative note' do
        expect( admin_note.note_editable_by?(admin.contact) ).to be(true)
      end
      it 'admin should be able to see administrative note' do
        expect( admin_note.show_note?(admin.contact) ).to be(true)
      end
      it 'shelter should not be able to edit administrative note' do
        expect( admin_note.note_editable_by?(shelter.contact) ).to be_falsy
      end
      it 'shelter should not be able to see administrative note' do
        expect( admin_note.show_note?(shelter.contact) ).to be_falsy
      end
    end
    context 'If shelter creates the note,' do
      it 'admin should be able to edit it' do
        match_note.update(contact_id: shelter.contact.id)
        expect( match_note.note_editable_by?(admin.contact) ).to be(true)
      end
      it 'shelter should be able to edit it' do
        match_note.update(contact_id: shelter.contact.id)
        expect( match_note.note_editable_by?(shelter.contact) ).to be(true)
      end
      it 'client contact should not be able to edit it' do
        match_note.update(contact_id: shelter.contact.id)
        expect( match_note.note_editable_by?(no_roles.contact) ).to be_falsy
      end
      it 'client contact should be able to see it' do
        match_note.update(contact_id: shelter.contact.id)
        expect( match_note.show_note?(no_roles.contact) ).to be(true)
      end
    end

    it 'Admin should not be able to create an administrative note' do
      expect( match.can_create_administrative_note? admin.contact ).to be(true)
    end
    it 'Shelter should not be able to create an administrative note' do
      match_note.update(contact_id: shelter.contact.id)
      expect( match.can_create_administrative_note? shelter.contact ).to be_falsy
    end
    
  end
end
