migration 8, :add_email_to_users do
  up do
    modify_table :users do
      add_column :email, String
    end
  end

  down do
    modify_table :users do
      drop_column :email
    end
  end
end
