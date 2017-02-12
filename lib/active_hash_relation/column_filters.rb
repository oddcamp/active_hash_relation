module ActiveHashRelation::ColumnFilters
  def filter_integer(resource, column, table_name, param)
    if param.is_a? Array
      n_param = param.to_s.gsub("\"","'").gsub("[","").gsub("]","") #fix this!
      if @is_not
        return resource.where.not("#{table_name}.#{column} IN (#{n_param})")
      else
        return resource.where("#{table_name}.#{column} IN (#{n_param})")
      end
    elsif param.is_a? Hash
      if !param[:null].nil?
        return null_filters(resource, table_name, column, param)
      else
        return apply_leq_geq_le_ge_filters(resource, table_name, column, param)
      end
    else
      if @is_not
        return resource.where.not("#{table_name}.#{column} = ?", param)
      else
        return resource.where("#{table_name}.#{column} = ?", param)
      end
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
      if @is_not
        return resource.where.not("#{table_name}.#{column} IN (#{n_param})")
      else
        return resource.where("#{table_name}.#{column} IN (#{n_param})")
      end
    elsif param.is_a? Hash
      if !param[:null].nil?
        return null_filters(resource, table_name, column, param)
      else
        return apply_like_filters(resource, table_name, column, param)
      end
    else
      if @is_not
        return resource.where.not("#{table_name}.#{column} = ?", param)
      else
        return resource.where("#{table_name}.#{column} = ?", param)
      end
    end
  end

  def filter_text(resource, column, param)
    return filter_string(resource, column, param)
  end

  def filter_date(resource, column, table_name, param)
    if param.is_a? Array
      n_param = param.to_s.gsub("\"","'").gsub("[","").gsub("]","") #fix this!
      if @is_not
        return resource.where.not("#{table_name}.#{column} IN (#{n_param})")
      else
        return resource.where("#{table_name}.#{column} IN (#{n_param})")
      end
    elsif param.is_a? Hash
      if !param[:null].nil?
        return null_filters(resource, table_name, column, param)
      else
        return apply_leq_geq_le_ge_filters(resource, table_name, column, param)
      end
    else
      if @is_not
        resource = resource.where.not(column => param)
      else
        resource = resource.where(column => param)
      end
    end

    return resource
  end

  def filter_datetime(resource, column, table_name, param)
    if param.is_a? Array
      n_param = param.to_s.gsub("\"","'").gsub("[","").gsub("]","") #fix this!
      if @is_not
        return resource = resource.where.not("#{table_name}.#{column} IN (#{n_param})")
      else
        return resource = resource.where("#{table_name}.#{column} IN (#{n_param})")
      end
    elsif param.is_a? Hash
      if !param[:null].nil?
        return null_filters(resource, table_name, column, param)
      else
        return apply_leq_geq_le_ge_filters(resource, table_name, column, param)
      end
    else
      if @is_not
        resource = resource.where.not(column => param)
      else
        resource = resource.where(column => param)
      end
    end

    return resource
  end

  def filter_boolean(resource, column, table_name, param)
    if param.is_a?(Hash) && !param[:null].nil?
      return null_filters(resource, table_name, column, param)
    else
      if ActiveRecord::VERSION::MAJOR >= 5
        b_param = ActiveRecord::Type::Boolean.new.cast(param)
      else
        b_param = ActiveRecord::Type::Boolean.new.type_cast_from_database(param)
      end

      if @is_not
        resource = resource.where.not(column => b_param)
      else
        resource = resource.where(column => b_param)
      end
    end
  end

  private

  def apply_leq_geq_le_ge_filters(resource, table_name, column, param)
    return resource.where("#{table_name}.#{column} = ?", param[:eq]) if param[:eq]

    if !param[:leq].blank?
      if @is_not
        resource = resource.where.not("#{table_name}.#{column} <= ?", param[:leq])
      else
        resource = resource.where("#{table_name}.#{column} <= ?", param[:leq])
      end
    elsif !param[:le].blank?
      if @is_not
        resource = resource.where.not("#{table_name}.#{column} < ?", param[:le])
      else
        resource = resource.where("#{table_name}.#{column} < ?", param[:le])
      end
    end

    if !param[:geq].blank?
      if @is_not
        resource = resource.where.not("#{table_name}.#{column} >= ?", param[:geq])
      else
        resource = resource.where("#{table_name}.#{column} >= ?", param[:geq])
      end
    elsif !param[:ge].blank?
      if @is_not
        resource = resource.where.not("#{table_name}.#{column} > ?", param[:ge])
      else
        resource = resource.where("#{table_name}.#{column} > ?", param[:ge])
      end
    end

    return resource
  end

  def apply_like_filters(resource, table_name, column, param)
    like_method = "LIKE"
    like_method = "ILIKE" if param[:with_ilike]

    if !param[:starts_with].blank?
      if @is_not
        resource = resource.where.not("#{table_name}.#{column} #{like_method} ?", "#{param[:starts_with]}%")
      else
        resource = resource.where("#{table_name}.#{column} #{like_method} ?", "#{param[:starts_with]}%")
      end
    end

    if !param[:ends_with].blank?
      if @is_not
        resource = resource.where.not("#{table_name}.#{column} #{like_method} ?", "%#{param[:ends_with]}")
      else
        resource = resource.where("#{table_name}.#{column} #{like_method} ?", "%#{param[:ends_with]}")
      end
    end

    if !param[:like].blank?
      if @is_not
        resource = resource.where.not("#{table_name}.#{column} #{like_method} ?", "%#{param[:like]}%")
      else
        resource = resource.where("#{table_name}.#{column} #{like_method} ?", "%#{param[:like]}%")
      end
    end

    if !param[:eq].blank?
      if @is_not
        resource = resource.where.not("#{table_name}.#{column} = ?", param[:eq])
      else
        resource = resource.where("#{table_name}.#{column} = ?", param[:eq])
      end
    end

    return resource
  end
  
  def null_filters(resource, table_name, column, param)
    if param[:null] == true
      if @is_not
        resource = resource.where.not("#{table_name}.#{column} IS NULL")
      else
        resource = resource.where("#{table_name}.#{column} IS NULL")
      end
    end
    
    if param[:null] == false
      if @is_not
        resource = resource.where.not("#{table_name}.#{column} IS NOT NULL")
      else
        resource = resource.where("#{table_name}.#{column} IS NOT NULL")
      end
    end
    
    return resource
  end
end
