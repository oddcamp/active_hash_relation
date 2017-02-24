module ActiveHashRelation::ScopeFilters
  def filter_scopes(resource, params, model = nil)
    unless model
      model = model_class_name(resource)
      if model.nil? || engine_name == model.to_s
        model = model_class_name(resource, true)
      end
    end

    model.scope_names.each do |scope|
      if params.include?(scope)
        if params[scope].is_a? Array
          resource = resource.send(scope, *params[scope])
        else
          resource = resource.send(scope)
        end
      end
    end

    return resource
  end
end
