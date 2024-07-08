# # Copyright (C) 2012-2024 Zammad Foundation, https://zammad-foundation.org/

# class OpenpoSupport < ActiveRecord::Migration[4.2]
#   def up

#     # return if it's a new setup
#     return if !Setting.exists?(name: 'system_init_done')

#     Setting.create_if_not_exists(
#     title:       'openproject integration',
#     name:        'openproject_integration',
#     area:        'Integration::Switch',
#     description: 'Defines if openproject is enabled or not.',
#     options:     {
#       form: [
#         {
#           display: '',
#           null:    true,
#           name:    'openproject_integration',
#           tag:     'boolean',
#           options: {
#             true  => 'yes',
#             false => 'no',
#           },
#         },
#       ],
#     },
#     state:       false,
#     preferences: {
#       prio:           1,
#       authentication: true,
#       permission:     ['admin.integration'],
#     },
#     frontend:    true
#   )
#   Setting.create_if_not_exists(
#     title:       'openproject config',
#     name:        'openproject_config',
#     area:        'Integration::Openproject',
#     description: 'Defines the openproject config.',
#     options:     {},
#     state:       {},
#     preferences: {
#       prio:       2,
#       permission: ['admin.integration'],
#     },
#     frontend:    false,
#   )
# end

# end
