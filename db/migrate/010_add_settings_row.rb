migration 10, :add_settings_row do
  up do
    Settings.new.save!
  end

  down do
    Settings.destroy
  end
end
