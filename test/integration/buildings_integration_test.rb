require "test_helper"

class BuildingsIntegrationTest < ActionDispatch::IntegrationTest

  include SmokeTest

  smoke_test 'index', "/buildings", as: [:public, :unprivileged_user, :hsa_admin, :dnd_staff], status: :redirect
  smoke_test 'index', "/buildings", as: [:admin]

end