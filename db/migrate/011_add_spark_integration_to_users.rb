migration 11, :add_spark_integration_to_users do
  up do
    modify_table :users do
      add_column :spark_integration, DataMapper::Property::Boolean
    end
  end

  down do
    modify_table :users do
      drop_column :spark_integration
    end
  end
end
