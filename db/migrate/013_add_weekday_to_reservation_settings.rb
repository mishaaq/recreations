migration 13, :add_weekday_to_reservation_settings do
  up do
    modify_table :reservation_settings do
      add_column :weekdays, DataMapper::Property::Flag
    end
    execute('UPDATE reservation_settings SET weekdays = 127')
  end

  down do
    modify_table :reservation_settings do
      drop_column :weekdays
    end
  end
end
