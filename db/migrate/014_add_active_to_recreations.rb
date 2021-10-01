migration 14, :add_active_to_recreations do
  up do
    modify_table :recreations do
      add_column :active, DataMapper::Property::Boolean
    end
    execute('UPDATE recreations SET active = "t"')
  end

  down do
    modify_table :recreations do
      drop_column :active
    end
  end
end
