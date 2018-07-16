Sequel.migration do
  up do
    create_table :discord_users do
      primary_key :id

      String :last_nick,  null: false
      # Based on Twitter's snowflake format https://github.com/twitter/snowflake/tree/snowflake-2010
      String :discord_id, null: false, unique: true

      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :updated_at
    end

    create_table :events do
      primary_key :id

      String  :stats_output_description
      String  :key,                  null: false, unique: true
      Boolean :show_in_stats_output, null: false, default: true
      Fixnum  :stats_output_order,   null: false, unique: true

      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :updated_at
    end

    create_table :event_counters do
      primary_key :id

      foreign_key :event_id,         :events,        null: false, on_update: :cascade, on_delete: :cascade
      foreign_key :discord_user_id,  :discord_users, null: false, on_update: :cascade, on_delete: :cascade

      Fixnum :count, null: false, default: 0

      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :updated_at
    end
  end

  down do
    drop_table :event_counters
    drop_table :events
    drop_table :discord_users
  end
end
