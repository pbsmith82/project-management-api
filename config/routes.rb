Rails.application.routes.draw do
  # Authentication
  post '/auth/register', to: 'auth#register'
  post '/auth/login', to: 'auth#login'
  get '/auth/me', to: 'auth#me'
  
  # Search
  get '/search', to: 'search#index'
  
  # Analytics
  get '/analytics', to: 'analytics#index'
  
  # AI Features
  post '/ai/generate_description', to: 'ai#generate_description'
  post '/ai/generate_acceptance_criteria', to: 'ai#generate_acceptance_criteria'
  post '/ai/suggest_tags', to: 'ai#suggest_tags'
  get '/ai/calculate_risk/:project_id', to: 'ai#calculate_risk'
  get '/ai/generate_insights', to: 'ai#generate_insights'
  get '/ai/semantic_search', to: 'ai#semantic_search'
  get '/ai/find_similar/:project_id', to: 'ai#find_similar'
  get '/ai/detect_duplicates/:project_id', to: 'ai#detect_duplicates'
  
  # Comments
  resources :comments, only: [:index, :create, :destroy] do
    collection do
      get ':resource_type/:resource_id', to: 'comments#index'
      post ':resource_type/:resource_id', to: 'comments#create'
    end
  end
  
  # Attachments
  resources :attachments, only: [:create, :destroy] do
    collection do
      post ':resource_type/:resource_id', to: 'attachments#create'
      delete ':resource_type/:resource_id/:id', to: 'attachments#destroy'
    end
  end
  
  # Action Cable
  mount ActionCable.server => '/cable'
  
  # Existing routes
  resources :project_types
  resources :stories
  resources :projects

  resources :projects do
    resources :stories, only: [:index, :new, :create]
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
