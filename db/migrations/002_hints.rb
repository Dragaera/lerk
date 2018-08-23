Sequel.migration do
  up do
    create_table :hints do
      primary_key :id

      String    :identifier,     null: false, unique: true
      String    :text,           null: false
      TrueClass :group_basic,    null: false, default: true
      TrueClass :group_advanced, null: false, default: true
      TrueClass :group_veteran,  null: false, default: true

      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :updated_at
    end

    create_table :hint_tags do
      primary_key :id

      String :tag, null: false, unique: true
    end

    create_join_table hint_tag_id: :hint_tags, hint_id: :hints
  end

  down do
    drop_table :hint_tags_hints
    drop_table :hints
    drop_table :hint_tags
  end
end
