class CreateBase < ActiveRecord::Migration[4.2]
    def self.up
        user_id = 1 # oder die ID eines anderen existierenden Benutzers
        #Ticket::Article::Type.create_if_not_exists(id: 15, name: 'openproject task', communication: true, created_by_id: user_id, updated_by_id: user_id)

        ActiveRecord::Migration.create_table :openproject_configs do |t|
          t.string :name, limit: 255, null: false
          t.string :op_url, limit: 255, null: false
          t.string :apikey, limit: 255, null: false
          t.references :created_by, null: false, foreign_key: { to_table: :users }
          t.references :updated_by, null: false, foreign_key: { to_table: :users }
          t.timestamps null: false, limit: 3
        end
        

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
      
      Permission.find_by(name: 'admin.openproject').destroy
      ActiveRecord::Migration.drop_table(:openproject_configs)

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