require "active_record/scope_names"
require "active_hash_relation/version"
require "active_hash_relation/column_filters"
require "active_hash_relation/scope_filters"
require "active_hash_relation/sort_filters"
require "active_hash_relation/limit_filters"
require "active_hash_relation/association_filters"
require "active_hash_relation/filter_applier"

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

  class Configuration
    attr_accessor :has_filter_classes, :filter_class_prefix, :filter_class_suffix
  end

end
