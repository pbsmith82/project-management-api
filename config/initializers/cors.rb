# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow requests from frontend domain
    origins [
      'https://projectmanagement.phillipbsmith.com',
      'http://localhost:3001',
      'http://localhost:3000',
      /http:\/\/localhost:\d+/
    ]

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,  # Changed to true if you're sending cookies/auth
      expose: ['Authorization'],  # Add if using JWT tokens
      max_age: 86400
  end
end