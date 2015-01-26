module ActiveJsonRelation::Filters
  def filter_associations(resource, params, model: nil)
    unless model
      model = model_class_name(resource)
    end

    model.reflect_on_all_associations.map(&:name).each do |association|
      if params[association]
        association_name = association.to_s.titleize.split.join
        association_filters = ActiveJsonRelation::FilterApplier.new(
          association_name.singularize.constantize.all,
          params[association],
          include_associations: true
        ).apply_filters
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
