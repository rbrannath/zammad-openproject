class App.OpenprojectConfig extends App.Model
  @configure 'OpenprojectConfig', 'name', 'apikey', 'op_url'
  @extend Spine.Model.Ajax
  @url: @apiPath + '/openproject_config'
  @configure_attributes = [
    { name: 'name', display: __('Name'), tag: 'input', type: 'text', limit: 100,  null: false },
    { name: 'op_url', display: __('URL'), tag: 'input', type: 'text', limit: 100,  null: false },
    { name: 'apikey', display: __('API-Key'), tag: 'input', type: 'text', limit: 100,  null: false },
  ]
  @configure_delete = true
  @configure_clone = true
  @configure_overview = [
    'name',
    'op_url',
    'apikey',
  ]

  @description = __('Manage OpenProject')