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
end
