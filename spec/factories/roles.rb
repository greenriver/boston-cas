FactoryGirl.define do
  factory :admin_role, class: 'Role' do
    name "admin"
    can_view_all_clients true
    can_edit_all_clients true
    can_participate_in_matches true
    can_view_all_matches true
    can_view_own_closed_matches true
    can_see_alternate_matches true
    can_edit_match_contacts true
    can_approve_matches true
    can_reject_matches true
    can_act_on_behalf_of_match_contacts true
    can_view_reports true
    can_edit_roles true 
    can_edit_users true 
    can_view_full_ssn true 
    can_view_full_dob true
    can_view_dmh_eligibility true
    can_view_va_eligibility true
    can_view_hues_eligibility true
    can_view_hiv_positive_eligibility true
    can_view_client_confidentiality true
    can_view_buildings true 
    can_edit_buildings true 
    can_view_funding_sources true
    can_edit_funding_sources true 
    can_view_subgrantees true 
    can_edit_subgrantees true
    can_view_vouchers true 
    can_edit_vouchers true 
    can_view_programs true 
    can_edit_programs true 
    can_view_opportunities true 
    can_edit_opportunities true 
    can_reissue_notifications true 
    can_view_units true 
    can_edit_units true 
    can_add_vacancies true
    can_view_contacts true
    can_edit_contacts true
    can_view_rule_list true
    can_edit_rule_list true
    can_view_available_services true
    can_edit_available_services true
    can_assign_services true
    can_assign_requirements true
    can_become_other_users true 
    can_edit_translations true
    can_view_vspdats true
    can_create_overall_note true
    can_delete_client_notes true
  end

  factory :shelter_role, class: 'Role' do
    name "shelter"
    can_participate_in_matches true
    can_create_overall_note true
  end
end
