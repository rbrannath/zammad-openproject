# Copyright (C) 2012-2024 Zammad Foundation, https://zammad-foundation.org/

class CreateBase < ActiveRecord::Migration[5.1]
    def up
      user_id = 1
      Ticket::Article::Type.create_if_not_exists(id: 15, name: 'openproject task', communication: true, created_by_id: user_id, updated_by_id: user_id)

      # return if it's a new setup
      return if !Setting.exists?(name: 'system_init_done')
  
      Setting.create_if_not_exists(
      title:       'openproject integration',
      name:        'openproject_integration',
      area:        'Integration::Switch',
      description: 'Defines if openproject is enabled or not.',
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
      frontend:    true
    )
    Setting.create_if_not_exists(
      title:       'openproject config',
      name:        'openproject_config',
      area:        'Integration::Openproject',
      description: 'Defines the openproject config.',
      options:     {},
      state:       {},
      preferences: {
        prio:       2,
        permission: ['admin.integration'],
      },
      frontend:    false,
    )
    Permission.create_if_not_exists(
      name:        'admin.openproject',
      note:        __('Manage %s'),
      preferences: {
        translations: [__('OpenProject')]
      },
    )

    {
      'assigned_to'                   => 'Zugewiesen an',
      'status'                        => 'Status',
      'priority'                      => 'Priorität',
      'assignee_update_success'       => 'Zuweisung wurde erfolgreich aktualisiert!',
      'status_update_success'         => 'Status wurde erfolgreich aktualisiert!',
      'priority_update_success'       => 'Priorität wurde erfolgreich aktualisiert!',
    }.each do |key, value|
      Translation.create_if_not_exists(
        locale:         'de-de',
        source:         key,
        target:         value,
        target_initial: value,
        updated_by_id:  1,
        created_by_id:  1,
      )
    end

  end
  
  def self.down
    ticket_article_type = Ticket::Article::Type.find_by(id: 15, name: 'openproject task')
    ticket_article_type.destroy if ticket_article_type
    [
      'assigned_to',
      'status',
      'priority',
      'assignee_update_success',
      'status_update_success',
      'priority_update_success',
    ].each do |key|
      translations = Translation.where(
        locale: 'de-de',
        source: key
      )
      translations.destroy_all
    end

  end

  end
  