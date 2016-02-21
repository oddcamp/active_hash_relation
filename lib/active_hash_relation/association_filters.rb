module ActiveHashRelation::AssociationFilters
  def filter_associations(resource, params, model = nil)
    unless model
      model = model_class_name(resource)
      if model.nil? || engine_name == model.to_s
        model = model_class_name(resource, true)
      end
    end

    model.reflect_on_all_associations.map(&:name).each do |association|
      if params[association]
        association_name = association.to_s.titleize.split.join
        if self.configuration.has_filter_classes
          if self.configuration.use_unscoped
            association_filters = self.filter_class(association_name).new(
              association_name.singularize.constantize.unscoped.all,
              params[association]
            ).apply_filters
          else
            association_filters = self.filter_class(association_name).new(
              association_name.singularize.constantize.all,
              params[association]
            ).apply_filters
          end
        else
          if self.configuration.use_unscoped
            association_filters = ActiveHashRelation::FilterApplier.new(
              association_name.singularize.constantize.unscoped.all,
              params[association],
              include_associations: true
            ).apply_filters
          else
            association_filters = ActiveHashRelation::FilterApplier.new(
              association_name.singularize.constantize.all,
              params[association],
              include_associations: true
            ).apply_filters
          end
        end
        resource = resource.joins(association).merge(association_filters)
      end
    end

    return resource
  end
end
