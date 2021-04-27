Rails.application.routes.draw do
  resources :project_types
  resources :stories
  resources :projects

  resources :projects do
    resources :stories, only: [:index, :new, :create]
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
