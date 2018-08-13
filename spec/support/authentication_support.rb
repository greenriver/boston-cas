module AuthenticationSupport
  module Controller
    def sign_in_as_admin
      admin = create(:admin)
      sign_in_as(user: admin, role: :admin)
      admin
    end

    def sign_in_as_member(user = create(:user))
      user.skip_confirmation!
      sign_in_as(user: user)
      user
    end

    def sign_in_as(user:, role: :user)
      @request.env["devise.mapping"] = Devise.mappings[role]
      user = user
      user.skip_confirmation!
      sign_in(user)
    end
  end

  module Feature
    def page!
      save_and_open_page
    end

    def sign_in_as_admin
      admin = create(:admin)
      admin.skip_confirmation!
      login_as(admin, scope: :user, run_callbacks: false)
      admin
    end

    def sign_in_as_member(user = create(:user))
      user.skip_confirmation!
      login_as(user, scope: :user, run_callbacks: false)
      user
    end

    def wait_until(timeout = Capybara.default_max_wait_time)
      require "timeout"
      Timeout.timeout(timeout) do
        sleep(0.2) until value = yield
        value
      end
    end
  end
end
