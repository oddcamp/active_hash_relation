require "active_json_relation/version"

module ActiveJsonRelation
  def apply_filters(resource, params, include_associations: false, model: nil)
    unless model
      model = model_class_name(resource)
    end
    table_name = model.table_name
    model.columns.each do |c|
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

    return self.send(:filter_associations, resource)
    #return resource
  end

  private

  def filter_associations(resource, model: nil)
    unless model
      model = model_class_name(resource)
    end

    model.reflect_on_all_associations.map(&:name).each do |association|
      if params[association]
        association_name = association.to_s.titleize.split.join
        association_filters = self.apply_filters(
          association_name.singularize.constantize.all,
          params[association],
          include_associations: true
        )
        resource = resource.joins(association).merge(association_filters)
      end
    end

    return resource
  end

  def model_class_name(resource)
    resource.class.to_s.split('::').first.constantize
  end


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
