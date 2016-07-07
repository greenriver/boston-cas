require "test_helper"

class OpportunitiesIntegrationTest < ActionDispatch::IntegrationTest

  include SmokeTest

  smoke_test 'index', "/opportunities", as: [:public, :unprivileged_user, :hsa_admin], status: :redirect
  smoke_test 'index', "/opportunities", as: [:admin, :dnd_staff ]

end