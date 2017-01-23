RSpec.configure do |config|
  config.before :suite do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end

class HelperClass
  include ActiveHashRelation
end

module Helpers
  def strip(query)
    query.gsub("\"","").gsub(/\s+/, ' ')
  end

  def select_all(table)
    ExpectedQuery.new("SELECT #{table}.* FROM users WHERE")
  end
  alias_method :select_all_where, :select_all

  def query(str)
    ExpectedQuery.new(str, subquery: true)
  end

  def q(*args)
    args.join(' ')
  end
end

class Array
  def avg
    sum / size.to_f
  end
end
