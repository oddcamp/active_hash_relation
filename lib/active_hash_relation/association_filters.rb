module ActiveHashRelation::AssociationFilters
  def filter_associations(resource, params, model: nil)
    unless model
      model = model_class_name(resource)
    end

    model.reflect_on_all_associations.map(&:name).each do |association|
      if params[association]
        association_name = association.to_s.titleize.split.join
        association_filters = ActiveHashRelation::FilterApplier.new(
          association_name.singularize.constantize.all,
          params[association],
          include_associations: true
        ).apply_filters
        resource = resource.joins(association).merge(association_filters)
      end
    end

    return resource
  end
end
