# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  get 'restricted' => 'home#restricted'

  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
end
