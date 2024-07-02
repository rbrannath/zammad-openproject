# config/routes/integration_openproject.rb
Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  match api_path + '/integration/openproject', to: 'integration/openproject#query', via: :post
  match api_path + '/integration/openproject', to: 'integration/openproject#query', via: :get
  match api_path + '/integration/openproject/verify', to: 'integration/openproject#verify', via: :post
  match api_path + '/integration/openproject', to: 'integration/openproject#update', via: :post
end
