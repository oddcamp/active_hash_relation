module ActiveHashRelation::ScopeFilters
  def filter_scopes(resource, params, model: nil)
    unless model
      model = model_class_name(resource)
    end

    model.scope_names.each do |scope|
      if params.include?(scope)
        resource = resource.send(scope)
      end
    end

    return resource
  end
end
