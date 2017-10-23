migration 3, :create_reservations do
  up do
    create_table :reservations do
      column :id, Integer, :serial => true
      column :time, DataMapper::Property::DateTime
      column :user_id, DataMapper::Property::Integer
      column :recreation_id, DataMapper::Property::Integer
    end
  end

  down do
    drop_table :reservations
  end
end
