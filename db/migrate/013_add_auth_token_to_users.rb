migration 13, :add_auth_token_to_users do
  up do
    modify_table :users do
      add_column :auth_token, String
    end
  end

  down do
    modify_table :users do
      drop_column :auth_token
    end
  end
end
