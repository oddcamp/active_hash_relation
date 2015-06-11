module ActiveHashRelation
  class FilterApplier
    include Helpers
    include ColumnFilters
    include AssociationFilters
    include ScopeFilters
    include SortFilters
    include LimitFilters

    attr_reader :configuration

    def initialize(resource, params, include_associations: true, model: nil)
      @configuration = Module.nesting.last.configuration
      @resource = resource
      @params = HashWithIndifferentAccess.new(params)
      @include_associations = include_associations
      @model = model
    end


    def apply_filters
      unless @model
        @model = model_class_name(@resource)
      end
      table_name = @model.table_name
      @model.columns.each do |c|
        next if @params[c.name.to_s].nil?

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
        when :string
          @resource = filter_string(@resource, c.name, table_name, @params[c.name])
        when :date
          @resource = filter_date(@resource, c.name, table_name, @params[c.name])
        when :datetime, :timestamp
          @resource = filter_datetime(@resource, c.name, table_name, @params[c.name])
        when :boolean
          @resource = filter_boolean(@resource, c.name, @params[c.name])
        end
      end


      @resource = filter_scopes(@resource, @params[:scopes]) if @params.include?(:scopes)
      @resource = filter_associations(@resource, @params) if @include_associations
      @resource = apply_limit(@resource, @params[:limit]) if @params.include?(:limit)
      @resource = apply_sort(@resource, @params[:sort], @model) if @params.include?(:sort)

      return @resource
    end

    def filter_class(resource_name)
      "#{configuration.filter_class_prefix}#{resource_name.pluralize}#{configuration.filter_class_suffix}".constantize
    end
  end
end
