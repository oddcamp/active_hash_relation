module ActiveHashRelation
  class Aggregation
    include Helpers

    attr_reader :configuration, :params, :resource, :model

    def initialize(resource, params, model: nil)
      @configuration = Module.nesting.last.configuration
      @resource = resource
      @params = HashWithIndifferentAccess.new(params)
      @model = model

      unless @model
        @model = model_class_name(@resource)
      end
    end

    def apply
      if params[:aggregate].is_a? Hash
        meta_attributes = HashWithIndifferentAccess.new

        @model.columns.each do |c|
          next unless params[:aggregate][c.name.to_s].is_a? Hash

          case c.type
          when :integer, :float, :decimal
            meta_attributes[c.name.to_s] = apply_aggregations(
              {avg: :average, sum: :sum, max: :maximum, min: :minimum},
              params[:aggregate][c.name.to_s],
              c.name.to_s
            )
          when :date, :datetime, :timestamp
            meta_attributes[c.name.to_s] = apply_aggregations(
              {max: :maximum, min: :minimum},
              params[:aggregate][c.name.to_s],
              c.name.to_s
            )
          end
        end
      end

      return meta_attributes
    end

    def apply_aggregations(available_aggr, asked_aggr, column)
      meta_attributes = HashWithIndifferentAccess.new

      available_aggr.each do |k, v|
        if asked_aggr[k] == true
          meta_attributes[k] = resource.send(v,column)
          meta_attributes[k] = meta_attributes[k].to_f if meta_attributes[k].is_a? BigDecimal
        end
      end

      return meta_attributes
    end
  end
end
