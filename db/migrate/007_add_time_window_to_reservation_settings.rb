migration 7, :add_time_window_to_reservation_settings do
  up do
    modify_table :reservation_settings do
      add_column :available_from, DateTime
      add_column :available_to, DateTime
    end
    execute('UPDATE reservation_settings SET available_from = "1970-01-01T08:00:00+00:00", available_to = "1970-01-01T17:00:00+00:00"')
  end

  down do
    modify_table :reservation_settings do
      drop_column :available_from
      drop_column :available_to
    end
  end
end
