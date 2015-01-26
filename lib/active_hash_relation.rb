require "active_record/scope_names"
require "active_hash_relation/version"
require "active_hash_relation/column_filters"
require "active_hash_relation/scope_filters"
require "active_hash_relation/association_filters"
require "active_hash_relation/filter_applier"

module ActiveHashRelation
  def apply_filters(resource, params, include_associations: false, model: nil)
    FilterApplier.new(
      resource,
      params,
      include_associations: include_associations,
      model: model
    ).apply_filters
  end
end
