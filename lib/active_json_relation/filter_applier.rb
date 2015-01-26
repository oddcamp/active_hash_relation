module ActiveHashRelation
  class FilterApplier
    include Filters

    def initialize(resource, params, include_associations: false, model: nil)
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

        @resource = filter_primary(@resource, c.name, @params[c.name]) and next if c.primary
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

      return self.send(:filter_associations, @resource, @params)
      #return resource
    end

  end
end
