migration 9, :create_settings do
  up do
    create_table :settings do
      column :id, Integer, :serial => true
      column :spark_bot_auth_code, DataMapper::Property::String, :length => 255
    end
  end

  down do
    drop_table :settings
  end
end
