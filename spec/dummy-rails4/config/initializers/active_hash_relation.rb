ActiveHashRelation.configure do |config|
  #override default scope when accessing associations
  config.use_unscoped = true
  #set true to be able to filter scopes (with params)
  #please note that unfortunately (:/) rails does not provide any way
  #to iterate through scopes so it uses a monkey patch
  #You need to run `initialize!` to actually include the required files
  config.filter_active_record_scopes = true
end

#requires monkeyparched scopes, optional if you don't enable them
ActiveHashRelation.initialize!
