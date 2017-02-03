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
      @model = find_model(model)
    end

    def apply_filters
      run_or_filters

      table_name = @model.table_name
      @model.columns.each do |c|
        next if @params[c.name.to_s].nil?
        next if @params[c.name.to_s].is_a?(String) && @params[c.name.to_s].blank?

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

      if @params.include?(:scopes)
        if ActiveHashRelation.configuration.filter_active_record_scopes
          @resource = filter_scopes(@resource, @params[:scopes], @model)
        else
          Rails.logger.warn('Ignoring ActiveRecord scope filters because they are not enabled')
        end
      end
      @resource = filter_associations(@resource, @params, @model) if @include_associations
      @resource = apply_limit(@resource, @params[:limit]) if @params.include?(:limit)
      @resource = apply_sort(@resource, @params[:sort], @model) if @params.include?(:sort)

      return @resource
    end

    def filter_class(resource_name)
      "#{configuration.filter_class_prefix}#{resource_name.pluralize}#{configuration.filter_class_suffix}".constantize
    end

    def run_or_filters
      if @params[:or].is_a?(Array)
        if ActiveRecord::VERSION::MAJOR < 5
          return Rails.logger.warn("OR query is supported on ActiveRecord 5+") 
        end

        if @params[:or].length >= 2
          array = @params[:or].map do |or_param|
            self.class.new(@resource, or_param, include_associations: @include_associations).apply_filters
          end

          @resource = @resource.merge(array[0])
          array[1..-1].each{|query| @resource = @resource.or(query)}
        else
          Rails.logger.warn("Can't run an OR with 1 element!")
        end
      end
    end
  end
end
