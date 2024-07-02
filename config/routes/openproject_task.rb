Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  match api_path + '/openproject_task',                 to: 'openproject_task#index',   via: :get
  match api_path + '/openproject_task_update_status',   to: 'openproject_task#updateStatus',   via: :put
  match api_path + '/openproject_task_update_assignee', to: 'openproject_task#updateAssignee',   via: :put
  match api_path + '/openproject_task_update_priority', to: 'openproject_task#updatePriority',   via: :put
  match api_path + '/openproject_task_delete',          to: 'openproject_task#deleteTask',   via: :put
  match api_path + '/openproject_task/:id',             to: 'openproject_task#show',    via: :get
  match api_path + '/openproject_task',                 to: 'openproject_task#create',  via: :post
  match api_path + '/openproject_task/:id',             to: 'openproject_task#update',  via: :put
  match api_path + '/openproject_task/:id',             to: 'openproject_task#destroy', via: :delete
end