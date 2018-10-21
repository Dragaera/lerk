Sequel.migration do
  up do
    alter_table :discord_users do
      add_column :steam_account_id, Integer
    end
  end

  down do
    alter_table :discord_users do
      drop_column :steam_account_id
    end
  end
end
