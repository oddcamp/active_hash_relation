module ActiveHashRelation
  class FilterApplier
    include Helpers
    include ColumnFilters
    include AssociationFilters
    include ScopeFilters
    include SortFilters
    include LimitFilters

    attr_reader :configuration

    def initialize(resource, params, include_associations: false, model: nil)
      @configuration = Module.nesting.last.configuration
      @resource = resource
      if params.respond_to?(:to_unsafe_h)
        @params = HashWithIndifferentAccess.new(params.to_unsafe_h)
      else
        @params = HashWithIndifferentAccess.new(params)
      end
      @include_associations = include_associations
      @model = model
    end


    def apply_filters
      unless @model
        @model = model_class_name(@resource)
        if @model.nil? || engine_name == @model.to_s
          @model = model_class_name(@resource, true)
        end
      end
      table_name = @model.table_name
      @model.columns.each do |c|
        next if @params[c.name.to_s].nil?
        next if @params[c.name.to_s].is_a?(String) && @params[c.name.to_s].blank?

        if c.respond_to?(:primary)
          if c.primary
            @resource = filter_primary(@resource, c.name, @params[c.name])
            next
          end
        else #rails 4.2
          if @model.primary_key == c.name
            @resource = filter_primary(@resource, c.name, @params[c.name])
            next
          end
        end

        case c.type
        when :integer
          @resource = filter_integer(@resource, c.name, table_name, @params[c.name])
        when :float
          @resource = filter_float(@resource, c.name, table_name, @params[c.name])
        when :decimal
          @resource = filter_decimal(@resource, c.name, table_name, @params[c.name])
        when :string, :uuid, :text
          @resource = filter_string(@resource, c.name, table_name, @params[c.name])
        when :date
          @resource = filter_date(@resource, c.name, table_name, @params[c.name])
        when :datetime, :timestamp
          @resource = filter_datetime(@resource, c.name, table_name, @params[c.name])
        when :boolean
          @resource = filter_boolean(@resource, c.name, table_name, @params[c.name])
        end
      end


      @resource = filter_scopes(@resource, @params[:scopes], @model) if @params.include?(:scopes)
      @resource = filter_associations(@resource, @params, @model) if @include_associations
      @resource = apply_limit(@resource, @params[:limit]) if @params.include?(:limit)
      @resource = apply_sort(@resource, @params[:sort], @model) if @params.include?(:sort)

      return @resource
    end

    def filter_class(resource_name)
      "#{configuration.filter_class_prefix}#{resource_name.pluralize}#{configuration.filter_class_suffix}".constantize
    end
  end
end
