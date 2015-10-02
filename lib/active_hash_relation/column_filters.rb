module ActiveHashRelation::ColumnFilters
  def filter_primary(resource, column, param)
    resource = resource.where(id: param)
  end

  def filter_integer(resource, column, table_name, param)
    if !param.is_a? Hash
      return resource.where(column => param)
    else
      return apply_leq_geq_le_ge_filters(resource, table_name, column, param)
    end
  end

  def filter_float(resource, column, table_name, param)
    filter_integer(resource, column, table_name, param)
  end

  def filter_decimal(resource, column, table_name, param)
    filter_integer(resource, column, table_name, param)
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
      return apply_leq_geq_le_ge_filters(resource, table_name, column, param)
    end

    return resource
  end

  def filter_datetime(resource, column, table_name, param)
    if !param.is_a? Hash
      resource = resource.where(column => param[column])
    else
      return apply_leq_geq_le_ge_filters(resource, table_name, column, param)
    end

    return resource
  end

  def filter_boolean(resource, column, param)
    b_param = ActiveRecord::Type::Boolean.new.type_cast_from_database(param)

    resource = resource.where(column => b_param)
  end

  private

  def apply_leq_geq_le_ge_filters(resource, table_name, column, param)
    if !param[:leq].blank?
      resource = resource.where("#{table_name}.#{column} <= ?", param[:leq])
    elsif !param[:le].blank?
      resource = resource.where("#{table_name}.#{column} < ?", param[:le])
    end

    if !param[:geq].blank?
      resource = resource.where("#{table_name}.#{column} >= ?", param[:geq])
    elsif !param[:ge].blank?
      resource = resource.where("#{table_name}.#{column} > ?", param[:ge])
    end

    return resource
  end
end
