Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  devise_for :users, controllers: { invitations: 'users/invitations', sessions: 'users/sessions'}
  devise_scope :user do
    match 'active' => 'users/sessions#active', via: :get
    match 'timeout' => 'users/sessions#timeout', via: :get
    match 'users/invitations/confirm', via: :post
  end

  namespace :users do
    resources :invitations do
      collection do
        post :confirm
      end
    end
  end

  concern :restorable do
    member { post 'restore' }
  end

  resources :clients, only: [:index, :show, :update] do
    resource :contacts, only: [:edit, :update], controller: :client_contacts, concerns: [:restorable]
    patch :unavailable, on: :member
    resources :unavailable_on_route, only: [:destroy]
    resources :matches, controller: 'client_matches', only: :index
    resources :closed_matches, controller: 'client_closed_matches', only: :index
    resources :client_notes, controller: 'client_notes', only: [:index, :destroy, :create]
    resources :qualified_opportunities, only: [:index, :update]
  end
  resources :unavailable_clients, only: [:index]
  resources :opportunities do
    post 'restore'
    resources :contacts, except: :show, controller: :opportunity_contacts, concerns: [:restorable]
    resources :matches, controller: 'opportunity_matches', only: [:index, :create, :update] do
      get :all, on: :collection
      get :closed, on: :collection
    end
  end
  resources :buildings do
    resources :contacts, except: :show, controller: :building_contacts, concerns: [:restorable]
    get :available_units, on: :member
    get :available_move_in_units, on: :member
    get :available_units_for_vouchers, on: :member
    get :units, on: :member
    resources :units, only: :new
  end
  resources :subgrantees do
    resources :contacts, except: :show, controller: :subgrantee_contacts, concerns: [:restorable]
  end
  resources :rules do
    get 'confirm_destroy', on: :member
    post 'restore', on: :member
  end
  resources :services, except: :show
  resources :funding_sources

  # concern that we can drop in at top level too
  # matches and their stuff can either be accessed directly if the user is logged in
  # or via a notification code
  def manage_matches
    resources :matches, only: [:show, :update] do
      get :history
      resources :decisions, only: [:show, :update], controller: 'match_decisions' do
        resource :acknowledgment, only: [:create], controller: 'match_decision_acknowledgments'
        get :recreate_notifications, on: :member
      end

      resource :contacts, only: [:edit, :update], controller: 'match_contacts'
      resources :notes, only: [:new, :create, :edit, :update, :destroy], controller: 'match_notes'
      resource :client_details, only: [:show], controller: 'match_client_details'
      resources :match_progress_updates, only: [:create], shallow: true
      resources :match_progress_update_notes, only: [:edit, :update, :destroy]
      get :reopen
    end
  end
  manage_matches

  resources :active_matches, only: :index
  resources :closed_matches, only: :index

  # also temporary, for testing
  namespace :testing do
    namespace :matching do
      resources :candidate_generations, only: %i{new create}
    end
  end

  resources :notifications, only: [:show] do
    manage_matches

    resources :buildings, only: :show do
      get :available_move_in_units, on: :member
    end

    resource :reissue_request, only: [:show]
    devise_scope :user do
      resources :sessions, only: [:new, :create], controller: 'notification_sessions'
      resources :registrations, only: [:new, :create], controller: 'notification_registrations'
    end

  end

  resources :contacts, except: :show do
    member do
      get :move_matches
      post :update_matches
    end
  end
  resources :units, except: :show, concerns: [:restorable]
  resources :programs do
    resources :sub_programs, only: [:new, :edit, :create, :update, :destroy] do
      member do
        get :close
      end

      resource :contacts, only: [:edit, :update], controller: :sub_program_contacts
      resources :vouchers, only: [:index, :create, :update, :destroy] do
        patch 'bulk_update', on: :collection
        delete :unavailable, on: :member
      end
      resources :in_progress_vouchers, only: [:index, :create, :update, :destroy] do
        patch 'bulk_update', on: :collection
        delete :unavailable, on: :member
      end
      resources :successful_vouchers, only: [:index, :create, :update, :destroy] do
        patch 'bulk_update', on: :collection
        delete :unavailable, on: :member
      end
      resource :program_details, only: [:edit, :update]
      resources :unit_for_building, only: [:new, :edit, :create, :update]
    end
  end
  resources :services

  namespace :admin do
    # resolves route clash w/ devise
    resources :users, except: [:show, :new, :create] do
      resource :resend_invitation, only: :create
      resource :recreate_invitation, only: :create
      resource :audit, only: :show
      resource :edit_history, only: :show
      resource :locations, only: :show
      patch :reactivate, on: :member
      member do
        post :confirm
        post :impersonate
      end
      collection do
        post :stop_impersonating
      end
    end
    resources :agencies
    resources :roles
    resources :versions, only: [:index]

    resources :translation_keys, only: [:index, :update]
    resources :translation_text, only: [:update]
    resources :configs, only: [:index] do
      patch :update, on: :collection
    end
    resources :match_routes, only: [:index, :edit, :update]
  end

  resources :neighborhoods
  resources :tags

  resource :account, only: [:edit, :update] do
    get :locations, on: :member
  end
  resource :account_email, only: [:edit, :update]
  resource :account_password, only: [:edit, :update]

  resources :resend_notification, only: [:show]

  resources :reports, only: [:index]
  namespace :reports do
    resources :parked_clients, only: [:index]
    namespace :dashboards do
      resources :overviews, only: [:index] do
        collection do
          get :details
        end
      end
      resources :vacancies, only: [:index] do
        collection do
          get :details
        end
      end
      resources :time_between_steps, only: [:index] do
        collection do
          get :details
          get :step_name_options
        end
      end
      resources :clients, only: [:index] do
        collection do
          get :client_details
          get :matches_details
        end
      end
    end
    resources :match_progress, only: [:index]
  end

  namespace :system_status do
    get :operational
    get :cache_status
    get :details
  end

  resources :deidentified_clients do
    collection do
      get :choose_upload
      post :import
    end
    member do
      get :new_assessment
      get :assessment
      get :current_assessment_limited
      patch :shelter_location
    end
  end
  resources :identified_clients do
    member do
      get :new_assessment
      get :assessment
      get :current_assessment_limited
      patch :shelter_location
    end
  end
  resources :imported_clients
  resources :messages, only: [:show, :index] do
    collection do
      get :poll
      post :seen
    end
  end

  resources :help

  unless Rails.env.production?
    resource 'style_guide', only: :none do
      get 'dnd_match_review'
      get 'icon_font'
      get 'match_contacts_modal'
      get 'stepped_progress'
      get 'tags'
      get 'typography'
      get 'summary'
      get 'pagination'
      get 'form'
    end
  end

  root 'root#index'
end
