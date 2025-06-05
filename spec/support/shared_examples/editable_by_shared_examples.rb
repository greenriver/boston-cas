# frozen_string_literal: true

RSpec.shared_examples 'client core visibility and editability' do |client_factory_name, perm_manage_all, perm_manage_non_all, perm_enter|
  # --- Common Setup ---
  let!(:user_agency) { create(:agency, name: "User Agency for #{client_factory_name}") }
  let!(:other_agency) { create(:agency, name: "Other Agency for #{client_factory_name}") }

  let!(:client_at_user_agency) { create(client_factory_name, agency: user_agency, first_name: "UserAgencyClient-#{client_factory_name.to_s.camelize}") }
  let!(:client_at_other_agency) { create(client_factory_name, agency: other_agency, first_name: "OtherAgencyClient-#{client_factory_name.to_s.camelize}") }
  let!(:client_nil_agency) { create(client_factory_name, agency: nil, first_name: "NilAgencyClient-#{client_factory_name.to_s.camelize}") }

  let(:create_user_with_permission) do
    ->(permission_to_set) do
      user = create(:user, agency: user_agency)
      role_attributes = {
        name: "#{permission_to_set}_#{client_factory_name}",
      }
      # Initialize all relevant permissions to false, then set the desired one to true.
      # Add :can_edit_all_clients to the list of perms to initialize for comprehensive role setup.
      ([perm_manage_all, perm_manage_non_all, perm_enter, :can_edit_all_clients].uniq.compact - [nil]).each do |p|
        role_attributes[p] = false
      end
      role_attributes[permission_to_set] = true if permission_to_set

      role = create(:role, role_attributes)
      user.roles << role
      user
    end
  end

  let(:basic_user) { create(:user, agency: user_agency) } # User with no special roles/permissions by default

  let(:enable_pathways) do
    -> {
      record_class = build(client_factory_name).class
      allow(record_class).to receive(:pathways_enabled?).and_return(true)
    }
  end

  # --- Visibility Scope Tests (.visible_to) ---
  context 'class method .visible_to(user) scope' do
    let(:user_can_edit_all_globally_for_visibility) { create_user_with_permission.call(:can_edit_all_clients) }
    # For this context, ensure the user *only* has perm_manage_all and not can_edit_all_clients
    let(:user_with_only_manage_all_for_visibility) { create_user_with_permission.call(perm_manage_all) }

    context 'when user has role with can_edit_all_clients' do
      it 'returns all clients (user agency, other agency, nil agency)' do
        scope_results = described_class.visible_to(user_can_edit_all_globally_for_visibility)
        expect(scope_results).to contain_exactly(client_at_user_agency, client_at_other_agency, client_nil_agency)
      end
    end

    context 'when user has role with ONLY the specific manage_all permission' do
      it 'returns all clients (user agency, other agency, nil agency)' do
        scope_results = described_class.visible_to(user_with_only_manage_all_for_visibility)
        expect(scope_results).to contain_exactly(client_at_user_agency, client_at_other_agency, client_nil_agency)
      end
    end

    context 'when user has a basic role (no broad visibility permissions)' do
      it 'returns clients from their agency and nil agency only' do
        scope_results = described_class.visible_to(basic_user)
        expect(scope_results).to contain_exactly(client_at_user_agency, client_nil_agency)
        expect(scope_results).not_to include(client_at_other_agency)
      end
    end
  end

  # --- Instance Method Tests (#editable_by?) ---
  context 'instance method #editable_by?(user)' do
    context 'when user has role with ONLY the specific manage_all permission' do
      let(:user_with_only_manage_all_perm) { create_user_with_permission.call(perm_manage_all) }

      it 'returns true for clients at their own agency' do
        expect(client_at_user_agency.editable_by?(user_with_only_manage_all_perm)).to be true
      end
      it 'returns true for clients at other agencies' do
        expect(client_at_other_agency.editable_by?(user_with_only_manage_all_perm)).to be true
      end
    end

    context 'when user has role with ONLY the specific manage_non_all permission' do
      let(:user_with_only_manage_non_all_perm) { create_user_with_permission.call(perm_manage_non_all) }

      it 'returns true for clients at their own agency' do
        expect(client_at_user_agency.editable_by?(user_with_only_manage_non_all_perm)).to be true
      end
      it 'returns true for clients at other agencies' do
        expect(client_at_other_agency.editable_by?(user_with_only_manage_non_all_perm)).to be true
      end
    end

    context 'when user has role with ONLY the specific enter permission' do
      let(:user_with_only_enter_perm) { create_user_with_permission.call(perm_enter) }

      context 'and pathways are disabled' do
        it 'returns true for clients at their own agency' do
          expect(client_at_user_agency.editable_by?(user_with_only_enter_perm)).to be true
        end
        it 'returns false for clients at other agencies' do
          expect(client_at_other_agency.editable_by?(user_with_only_enter_perm)).to be false
        end
      end

      context 'and pathways are enabled' do
        before { enable_pathways.call }
        it 'returns true for clients at their own agency' do
          expect(client_at_user_agency.editable_by?(user_with_only_enter_perm)).to be true
        end
        it 'returns true for clients at other agencies' do
          expect(client_at_other_agency.editable_by?(user_with_only_enter_perm)).to be true
        end
      end
    end

    context 'when user has no relevant permissions (basic_user)' do
      it 'returns false for clients at their own agency' do
        expect(client_at_user_agency.editable_by?(basic_user)).to be false
      end
      it 'returns false for clients at other agencies' do
        expect(client_at_other_agency.editable_by?(basic_user)).to be false
      end
    end
  end

  # --- Scope Tests (.editable_by) ---
  context 'class method .editable_by(user) scope' do
    let(:user_can_edit_all_globally) { create_user_with_permission.call(:can_edit_all_clients) }
    let(:user_with_only_manage_all_scope_perm) { create_user_with_permission.call(perm_manage_all) }
    let(:user_with_only_manage_non_all_scope_perm) { create_user_with_permission.call(perm_manage_non_all) }
    let(:user_with_only_enter_scope_perm) { create_user_with_permission.call(perm_enter) }

    context 'when user has role with can_edit_all_clients' do
      it 'returns all clients (user agency, other agency, nil agency)' do
        scope_results = described_class.editable_by(user_can_edit_all_globally)
        expect(scope_results).to contain_exactly(client_at_user_agency, client_at_other_agency, client_nil_agency)
      end
    end

    context 'when user has role with ONLY the specific manage_all permission' do
      it 'returns all clients (user agency, other agency, nil agency)' do
        scope_results = described_class.editable_by(user_with_only_manage_all_scope_perm)
        expect(scope_results).to contain_exactly(client_at_user_agency, client_at_other_agency, client_nil_agency)
      end
    end

    context 'when user has role with ONLY the specific manage_non_all permission' do
      context 'and pathways are disabled' do
        it 'returns clients from their agency only' do
          scope_results = described_class.editable_by(user_with_only_manage_non_all_scope_perm)
          expect(scope_results).to contain_exactly(client_at_user_agency)
          expect(scope_results).not_to include(client_at_other_agency, client_nil_agency)
        end
      end
      context 'and pathways are enabled' do
        before { enable_pathways.call }
        it 'returns all clients (user agency, other agency, nil agency)' do
          scope_results = described_class.editable_by(user_with_only_manage_non_all_scope_perm)
          expect(scope_results).to contain_exactly(client_at_user_agency, client_at_other_agency, client_nil_agency)
        end
      end
    end

    context 'when user has role with ONLY the specific enter permission' do
      context 'and pathways are disabled' do
        it 'returns clients from their agency only' do
          scope_results = described_class.editable_by(user_with_only_enter_scope_perm)
          expect(scope_results).to contain_exactly(client_at_user_agency)
          expect(scope_results).not_to include(client_at_other_agency, client_nil_agency)
        end
      end
      context 'and pathways are enabled' do
        before { enable_pathways.call }
        it 'returns all clients (user agency, other agency, nil agency)' do
          scope_results = described_class.editable_by(user_with_only_enter_scope_perm)
          expect(scope_results).to contain_exactly(client_at_user_agency, client_at_other_agency, client_nil_agency)
        end
      end
    end

    context 'when user has no relevant editing permissions (basic_user)' do
      it 'returns no clients' do
        scope_results = described_class.editable_by(basic_user)
        expect(scope_results).to be_empty
      end
    end
  end
end
