Rails.application.routes.draw do
  devise_for :users, controllers: { invitations: 'users/invitations'}

  concern :restorable do
    member { post 'restore' }
  end

  resources :clients, only: [:index, :show, :update] do
    resources :contacts, except: :show, controller: :client_contacts, concerns: [:restorable]
    patch 'split', on: :member
    patch :unavailable, on: :member
    resources :duplicates, controller: 'client_duplicates', only: [:show, :update]
    resources :matches, controller: 'client_matches', only: :index
  end
  resources :opportunities do
    post 'restore'
    resources :contacts, except: :show, controller: :opportunity_contacts, concerns: [:restorable]
    resources :alternate_matches, controller: 'opportunity_alternate_matches', only: :index
    resources :matches, controller: 'opportunity_matches', only: :index
  end
  resources :buildings do
    resources :contacts, except: :show, controller: :building_contacts, concerns: [:restorable]
    get "available_units", on: :member
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
      resources :decisions, only: [:show, :update], controller: 'match_decisions' do
        resource :acknowledgment, only: [:create], controller: 'match_decision_acknowledgments'
        get :recreate_notifications, on: :member
      end
      
      resource :contacts, only: [:edit, :update], controller: 'match_contacts'
      resources :notes, only: [:new, :create, :edit, :update, :destroy], controller: 'match_notes'
      resource :client_details, only: [:show], controller: 'match_client_details'
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
    end
    resources :roles
  end
  resource :account, only: [:edit, :update]
  resources :reissue_notifications, only: [:index, :update, :destroy]
  resources :resend_notification, only: [:show]

  namespace :reports do
    resources :parked_clients, only: [:index]
  end
  
  unless Rails.env.production?
    resource 'style_guide', only: :none do
      get 'dnd_match_review'
      get 'match_contacts_modal'
      get 'icon_font'
    end
  end

  root 'root#index'
end
