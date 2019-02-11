migration 14, :add_reservation_settings_inheritance do
  up do
    modify_table :reservation_settings do
      add_column :type, DataMapper::Property::Discriminator, :default => ""
      add_column :max_guests, DataMapper::Property::Integer
      add_column :monday, DataMapper::Property::CommaSeparatedList
      add_column :tuesday, DataMapper::Property::CommaSeparatedList
      add_column :wednesday, DataMapper::Property::CommaSeparatedList
      add_column :thursday, DataMapper::Property::CommaSeparatedList
      add_column :friday, DataMapper::Property::CommaSeparatedList
      add_column :saturday, DataMapper::Property::CommaSeparatedList
      add_column :sunday, DataMapper::Property::CommaSeparatedList
    end

    execute('UPDATE reservation_settings SET type = "TimeBasedReservationSettings"')
  end

  down do
    modify_table :reservation_settings do
      drop_column :type
      drop_column :max_guests
      drop_column :monday
      drop_column :tuesday
      drop_column :wednesday
      drop_column :thursday
      drop_column :friday
      drop_column :saturday
      drop_column :sunday
    end
  end
end
