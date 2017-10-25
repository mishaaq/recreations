migration 6, :add_display_name_to_user do
  up do
    modify_table :users do
      add_column :display_name, String
    end
  end

  down do
    modify_table :users do
      drop_column :display_name
    end
  end
end
