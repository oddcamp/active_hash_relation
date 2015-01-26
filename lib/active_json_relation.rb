require "active_json_relation/version"
require "active_json_relation/filters"
require "active_json_relation/filter_applier"

module ActiveJsonRelation
  def apply_filters(resource, params, include_associations: false, model: nil)
    FilterApplier.new(
      resource,
      params,
      include_associations: include_associations,
      model: model
    ).apply_filters
  end
end
