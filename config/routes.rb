Rails.application.routes.draw do
  mount LetsencryptPlugin::Engine, at: '/'

  devise_for :users, controllers: { invitations: 'users/invitations', sessions: 'users/sessions'}
  devise_scope :user do
    match 'active' => 'users/sessions#active', via: :get
    match 'timeout' => 'users/sessions#timeout', via: :get
  end

  concern :restorable do
    member { post 'restore' }
  end

  resources :clients, only: [:index, :show, :update] do
    resources :contacts, except: :show, controller: :client_contacts, concerns: [:restorable]
    patch :unavailable, on: :member
    resources :matches, controller: 'client_matches', only: :index
    resources :client_notes, controller: 'client_notes', only: [:index, :destroy, :create]
    resources :qualified_opportunities, only: [:index, :update]
  end
  resources :opportunities do
    post 'restore'
    resources :contacts, except: :show, controller: :opportunity_contacts, concerns: [:restorable]
    resources :alternate_matches, controller: 'opportunity_alternate_matches', only: :index
    resources :matches, controller: 'opportunity_matches', only: :index
  end
  resources :buildings do
    resources :contacts, except: :show, controller: :building_contacts, concerns: [:restorable]
    get :available_units, on: :member
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
  resources :funding_sources, only: [:index, :edit, :update]

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
      resources :match_progress_updates, only: [:update], shallow: true
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
    resource :reissue_request, only: [:show]
    devise_scope :user do
      resources :sessions, only: [:new, :create], controller: 'notification_sessions'
      resources :registrations, only: [:new, :create], controller: 'notification_registrations'
    end

  end

  resources :contacts, except: :show
  resources :units, except: :show, concerns: [:restorable]
  resources :programs do
    resources :sub_programs, only: [:new, :edit, :create, :update, :destroy] do
      resource :contacts, only: [:edit, :update], controller: :program_contacts
      resources :vouchers, only: [:index, :create, :update, :destroy] do
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
      resource :become, only: [:show]
    end
    resources :roles
    resources :versions, only: [:index]

    resources :translation_keys, only: [:index, :update]
    resources :translation_text, only: [:update]
    resources :configs, only: [:index] do
      patch :update, on: :collection
    end
    resources :match_routes, only: [:index, :edit, :update]
  end
  resource :account, only: [:edit, :update]
  resources :resend_notification, only: [:show]

  namespace :reports do
    resources :parked_clients, only: [:index]
  end

  namespace :system_status do
    get :operational
  end

  
  resources :deidentified_clients, only: [:index, :new, :create, :edit, :update, :destroy,]
  resources :messages, only: [:show, :index] do
    collection do
      get :poll
      post :seen
    end
  end

  unless Rails.env.production?
    resource 'style_guide', only: :none do
      get 'dnd_match_review'
      get 'icon_font'
      get 'match_contacts_modal'
      get 'stepped_progress'
      get 'tags'
      get 'typography'
      get 'summary'
    end
  end

  root 'root#index'
end
