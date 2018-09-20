Sequel.migration do
  up do
    alter_table :discord_users do
      add_column :ignored, TrueClass, null: false, default: false
    end
  end

  down do
    alter_table :discord_users do
      drop_column :ignored
    end
  end
end
