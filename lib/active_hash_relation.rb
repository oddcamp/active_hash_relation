require_relative "active_hash_relation/version"
require_relative "active_hash_relation/helpers"
require_relative "active_hash_relation/column_filters"
require_relative "active_hash_relation/scope_filters"
require_relative "active_hash_relation/sort_filters"
require_relative "active_hash_relation/limit_filters"
require_relative "active_hash_relation/association_filters"
require_relative "active_hash_relation/filter_applier"

require_relative "active_hash_relation/aggregation"

module ActiveHashRelation
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new do
      self.has_filter_classes = false
      self.filter_active_record_scopes = false
    end
  end

  def self.initialize!
    if self.configuration.filter_active_record_scopes
      require_relative "active_record/scope_names"
    end
  end

  def apply_filters(resource, params, include_associations: false, model: nil)
    FilterApplier.new(
      resource,
      params,
      include_associations: include_associations,
      model: model
    ).apply_filters
  end

  def aggregations(resource, params, model: nil)
    Aggregation.new(resource, params, model: model).apply
  end

  class Configuration
    attr_accessor :has_filter_classes, :filter_class_prefix, :filter_class_suffix,
      :use_unscoped, :filter_active_record_scopes
  end
end
