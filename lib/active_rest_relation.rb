require "active_rest_relation/version"

module ActiveRestRelation
  def apply_filters(resource, params)
    model_class = resource.class.to_s.split('::').first.constantize
    table_name = model_class.table_name
    model_class.columns.each do |c|
      unless params[c.name.to_s].nil?
        resource = filter_primary(resource, c.name, params[c.name]) and next if c.primary
        case c.type
        when :integer
          resource = filter_integer(resource, c.name, params[c.name])
        when :string
          resource = filter_string(resource, c.name, table_name, params[c.name])
        when :date
          resource = filter_date(resource, c.name, table_name, params[c.name])
        when :datetime, :timestamp
          resource = filter_datetime(resource, c.name, table_name, params[c.name])
        when :boolean
          resource = filter_boolean(resource, c.name, params[c.name])
        end
      end
    end

    return resource
  end

  private

  def filter_primary(resource, column, param)
    resource = resource.where(id: param)
  end

  def filter_integer(resource, column, param)
    if !param.is_a? Hash
      return resource.where(column => param)
    else
      raise "We don't support hashes yet!"
    end
  end

  def filter_string(resource, column, table_name, param)
    resource = resource.where("#{table_name}.#{column} ILIKE ?", "%#{param}%")
  end

  def filter_text(resource, column, param)
    return filter_string(resource, column, param)
  end

  def filter_date(resource, column, table_name, param)
    if !param.is_a? Hash
      resource = resource.where(column => param[column])
    else
      if param[:leq]
        resource = resource.where("#{table_name}.#{column} <= ?", param[:leq])
      end

      if param[:geq]
        resource = resource.where("#{table_name}.#{column} >= ?", param[:geq])
      end
    end

    return resource
  end

  def filter_datetime(resource, column, table_name, param)
    if !param.is_a? Hash
      resource = resource.where(column => param[column])
    else
      if param[:leq]
        resource = resource.where("#{table_name}.#{column} <= ?", param[:leq])
      end

      if param[:geq]
        resource = resource.where("#{table_name}.#{column} >= ?", param[:geq])
      end
    end

    return resource
  end

  def filter_boolean(resource, column, param)
    b_param = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(param)

    resource = resource.where(column => b_param)
  end

end
