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
    if model.columns.map(&:name).include?(params[:property].to_s)
      resource = resource.order(params[:property] => (params[:order] || :desc) )
    end

    return resource
  end
end
