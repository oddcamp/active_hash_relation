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
