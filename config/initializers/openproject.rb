# config/initializers/openproject.rb
require_relative '../../lib/openproject/openproject'
# Zammad::PackageManager.register('openproject') do |package|
#     package.name        = 'OpenProject'
#     package.version     = '1.0.1'
#     package.description = 'Integration with OpenProject'
#     package.author      = 'Roy Brannath'
#   end

# config/initializers/openproject_settings.rb

Rails.application.config.after_initialize do
    Setting.create_if_not_exists(
      title:       __('openproject config'),
      name:        'openproject_config',
      area:        'Integration::Openproject',
      description: __('Defines the openproject config.'),
      options:     {},
      state:       {},
      preferences: {
        prio:       2,
        permission: ['admin.integration'],
      },
      frontend:    false,
    )
  
    Setting.create_if_not_exists(
      title:       __('openproject integration'),
      name:        'openproject_integration',
      area:        'Integration::Switch',
      description: __('Defines if the openproject integration is enabled or not.'),
      options:     {
        form: [
          {
            display: '',
            null:    true,
            name:    'openproject_integration',
            tag:     'boolean',
            options: {
              true  => 'yes',
              false => 'no',
            },
          },
        ],
      },
      state:       false,
      preferences: {
        prio:           1,
        authentication: true,
        permission:     ['admin.integration'],
      },
      frontend:    true,
    )
  end
  