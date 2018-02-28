class Settings
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :spark_bot_auth_code, String
end
