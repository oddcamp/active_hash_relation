module ActiveHashRelation::ColumnFilters
  def filter_primary(resource, column, param)
    resource = resource.where(id: param)
  end

  def filter_integer(resource, column, table_name, param)
    if param.is_a? Array
      n_param = param.to_s.gsub("\"","'").gsub("[","").gsub("]","") #fix this!
      return resource.where("#{table_name}.#{column} IN (#{n_param})")
    elsif param.is_a? Hash
      if !param[:null].blank?
        return null_filters(resource, table_name, column, param)
      else
        return apply_leq_geq_le_ge_filters(resource, table_name, column, param)
      end
    else
      return resource.where("#{table_name}.#{column} = ?", param)
    end
  end

  def filter_float(resource, column, table_name, param)
    filter_integer(resource, column, table_name, param)
  end

  def filter_decimal(resource, column, table_name, param)
    filter_integer(resource, column, table_name, param)
  end

  def filter_string(resource, column, table_name, param)
    if param.is_a? Array
      n_param = param.to_s.gsub("\"","'").gsub("[","").gsub("]","") #fix this!
      return resource.where("#{table_name}.#{column} IN (#{n_param})")
    elsif param.is_a? Hash
      if !param[:null].blank?
        return null_filters(resource, table_name, column, param)
      else
        return apply_like_filters(resource, table_name, column, param)
      end
    else
      return resource.where("#{table_name}.#{column} = ?", param)
    end
  end

  def filter_text(resource, column, param)
    return filter_string(resource, column, param)
  end

  def filter_date(resource, column, table_name, param)
    if param.is_a? Array
      n_param = param.to_s.gsub("\"","'").gsub("[","").gsub("]","") #fix this!
      return resource.where("#{table_name}.#{column} IN (#{n_param})")
    elsif param.is_a? Hash
      if !param[:null].blank?
        return null_filters(resource, table_name, column, param)
      else
        return apply_leq_geq_le_ge_filters(resource, table_name, column, param)
      end
    else
      resource = resource.where(column => param)
    end

    return resource
  end

  def filter_datetime(resource, column, table_name, param)
    if param.is_a? Array
      n_param = param.to_s.gsub("\"","'").gsub("[","").gsub("]","") #fix this!
      return resource = resource.where("#{table_name}.#{column} IN (#{n_param})")
    elsif param.is_a? Hash
      if !param[:null].blank?
        return null_filters(resource, table_name, column, param)
      else
        return apply_leq_geq_le_ge_filters(resource, table_name, column, param)
      end
    else
      resource = resource.where(column => param)
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

  def apply_like_filters(resource, table_name, column, param)
    like_method = "LIKE"
    like_method = "ILIKE" if param[:with_ilike]

    if !param[:starts_with].blank?
      resource = resource.where("#{table_name}.#{column} #{like_method} ?", "#{param[:starts_with]}%")
    end

    if !param[:ends_with].blank?
      resource = resource.where("#{table_name}.#{column} #{like_method} ?", "%#{param[:ends_with]}")
    end

    if !param[:like].blank?
      resource = resource.where("#{table_name}.#{column} #{like_method} ?", "%#{param[:like]}%")
    end

    if !param[:eq].blank?
      resource = resource.where("#{table_name}.#{column} = ?", param[:eq])
    end

    return resource
  end
  
  def null_filters(resource, table_name, column, param)
    if param[:null] == true
      resource = resource.where("#{table_name}.#{column} IS NULL")
    end
    
    if param[:null] == false
      resource = resource.where("#{table_name}.#{column} IS NOT NULL")
    end
    
    return resource
  end
end
