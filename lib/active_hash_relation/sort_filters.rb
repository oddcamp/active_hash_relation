module ActiveHashRelation::SortFilters
  def apply_sort(resource, params, model = nil)
    if params.is_a? Array
      params.each do |param_item|
        resource = apply_hash_sort(resource, param_item, model)
      end
    else
      resource = apply_hash_sort(resource, params, model)
    end

    return resource
  end

  def apply_hash_sort(resource, params, model = nil)
    if not params[:property].blank?
      if model.columns.map(&:name).include?(params[:property].to_s)
        resource = resource.order(params[:property] => (params[:order] || :desc) )
      end
    else
      params.each do |property, order|
        if model.columns.map(&:name).include?(property.to_s)
          resource = resource.order(property => (order || :desc) )
        end
      end
    end

    return resource
  end
end
