# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  get 'restricted' => 'home#restricted'

  get    'user/login'  => 'user_sessions#new'
  post   'user/login'  => 'user_sessions#create'
  delete 'user/logout' => 'user_sessions#destroy'
end
