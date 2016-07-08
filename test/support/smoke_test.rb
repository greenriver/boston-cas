module SmokeTest
  # Module designed to be mixed into integration tests
  # provides a convenient DSL for testing pages give specific responses when hit by a certain user

  extend ActiveSupport::Concern
  included do

    include Warden::Test::Helpers

    # A basic test of a 200 OK on a path
    # Options
    # :as => an array of user types to test as.  current types are :public, :unprivileged, :hsa_admin, :dnd_staff, and :admin.  Defaults to :public.
    def self.smoke_test(page_name, path, opts = {})

      expected_status = opts[:status] || :success

      test_as_users = Array.wrap( opts[:as].presence || @_default_smoke_test_as || :public )



      test_as_users.each do |user_type|
        user_for_test = self.get_user_for_test(user_type)
        self.test "#{page_name} sends #{expected_status} for #{user_type}" do

          begin
            if user_for_test
              login_as(user_for_test)
            end
            get path
            assert_response expected_status
          ensure
            Warden.test_reset!
          end

        end
      end
    end

    # e.g. 
    # class PrivligedAreaTest 
    #   include SmokeTest
    #   default_smoke_test_as :dnd_staff
    # #...
    # end
    def self.default_smoke_test_as(default_smoke_test_as)
      @_default_smoke_test_as = default_smoke_test_as
    end

    def self.get_user_for_test user_type
      @_user_factory ||= UserFactory.new
      case user_type
      when :admin then @_user_factory.admin
      when :dnd_staff then @_user_factory.dnd_staff
      when :hsa_admin then @_user_factory.hsa_admin
      when :unprivileged then @_user_factory.unprivileged_user
      else nil
      end
    end

  end # class_methods

end
