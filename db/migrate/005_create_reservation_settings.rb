migration 5, :create_reservation_settings do
  up do
    create_table :reservation_settings do
      column :id, Integer, :serial => true
      column :recreation_id, DataMapper::Property::Integer
      column :for_time, DataMapper::Property::DateTime
      column :slots, DataMapper::Property::Integer
    end
  end

  down do
    drop_table :reservation_settings
  end
end
