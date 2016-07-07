require "test_helper"

class ActiveMatchesIntegrationTest < ActionDispatch::IntegrationTest

  include SmokeTest

  smoke_test 'index', "/active_matches", as: [:public, :unprivileged_user], status: :redirect
  smoke_test 'index', "/active_matches", as: [:admin, :dnd_staff, :hsa_admin, ]

end