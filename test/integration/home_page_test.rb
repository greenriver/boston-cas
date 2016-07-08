require "test_helper"

class HomePageTest < ActionDispatch::IntegrationTest

  include SmokeTest

  smoke_test 'Home Page', '/', as: [:public, :hsa_admin, :dnd_staff, :admin]

end