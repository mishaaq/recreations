migration 1, :create_recreations do
  up do
    create_table :recreations do
      column :id, Integer, :serial => true
      column :name, DataMapper::Property::String, :length => 255
    end
  end

  down do
    drop_table :recreations
  end
end
