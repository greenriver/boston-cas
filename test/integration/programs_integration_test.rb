require "test_helper"

class ProgramsIntegrationTest < ActionDispatch::IntegrationTest

  include SmokeTest

  smoke_test 'index', "/programs", as: [:public, :unprivileged_user, :hsa_admin], status: :redirect
  smoke_test 'index', "/programs", as: [:admin, :dnd_staff ]

end