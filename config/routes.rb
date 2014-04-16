Chat::Application.routes.draw do

  resources :backgrounds, :only => [:new, :show, :create]
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "message/index", to: "message#index"
  resources :friendships, :only => [:create, :destroy]
  resources :users,:path => :persons, :only => [:index, :show]

  #FIXME resources do ?
  resources :messages, :only => [:show, :create]
  #get "message/:id", to: "message#show"
  #post "message", to: "message#create", as: "new_message"
  post "message/search", to: "message#search"
  get "message/search/:search", to: "message#search"
  get "users/search/:id", to: "users#search"

  get "message/search/:search", to: "message#search"
  resources :rooms, :only => [:new, :create, :show, :index, :destroy]
  resources :rooms_users, :only => [:create, :destroy]
  get "users/status/", :to=>"users#change_status"
  post "users/search", :to=>"users#search"
  post "users/invite_user", :to=>"users#invite_user", :as=>"invite_user"
  #post "rooms/del", :to=>"rooms#delete_room"
  post "rooms/previous_messages", :to=>"rooms#load_previous_10_msg", :as=>"previous_messages"
  post "rooms/change", to: "rooms#update"
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  post 'pusher/auth'
  post 'pusher/stat'

  devise_scope :user do
    root to: "devise/sessions#new"
  end
  match "rooms_users/:id/:room_id", :to => "rooms_users#destroy" , :as => "delete_user", :via => :delete

end
