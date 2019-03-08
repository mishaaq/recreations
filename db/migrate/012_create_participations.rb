migration 12, :create_participations do
  up do
    create_table :participations do
      column :id, Integer, :serial => true
      column :user_id, DataMapper::Property::Integer
      column :reservation_id, DataMapper::Property::Integer
    end
  end

  down do
    drop_table :participations
  end
end
