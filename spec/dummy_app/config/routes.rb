# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  get 'restricted' => 'home#restricted'

  get 'api/hello'      => 'hello#index'
  get 'api/restricted' => 'hello#restricted'

  get    'user/login'  => 'user_sessions#new'
  post   'user/login'  => 'user_sessions#create'
  delete 'user/logout' => 'user_sessions#destroy'

  get    'admin/login'  => 'admin_sessions#new'
  post   'admin/login'  => 'admin_sessions#create'
  delete 'admin/logout' => 'admin_sessions#destroy'

  post   'api/login'  => 'api_sessions#create'
  delete 'api/logout' => 'api_sessions#destroy'

  #############
  ## Plugins ##
  #############

  post 'plugins/activity_logging/login' => 'activity_logging#create'
  delete 'plugins/activity_logging/logout' => 'activity_logging#destroy'

  post 'plugins/brute_force_protection/login' => 'brute_force_protection#create'

  post 'plugins/http_basic_auth/restricted' =>
    'http_basic_auth#restricted_with_http_basic_auth'

  get 'plugins/oauth/test_create_from_provider' =>
    'oauth#test_create_from_provider'

  post 'plugins/remember_me/login_with_remember_me' =>
    'remember_me#login_with_remember_me'
  post 'plugins/remember_me/login_without_remember_me' =>
    'remember_me#login_without_remember_me'
  get 'plugins/remember_me/page_with_forget_me' =>
    'remember_me#page_with_forget_me'
  get 'plugins/remember_me/page_with_force_forget_me' =>
    'remember_me#page_with_force_forget_me'
  delete 'plugins/remember_me/logout' => 'remember_me#destroy'
  get 'plugins/remember_me/show_if_logged_in' => 'remember_me#show_if_logged_in'
  delete 'plugins/remember_me/purge_session' => 'remember_me#purge_session'
  post 'plugins/remember_me/login_with_remember_me_parameter' =>
    'remember_me#login_with_remember_me_parameter'
  post 'plugins/remember_me/login_with_login_as_user' =>
    'remember_me#login_with_login_as_user'
end
