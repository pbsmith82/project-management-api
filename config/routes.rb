Rails.application.routes.draw do
  resources :project_types
  resources :stories
  resources :projects
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
