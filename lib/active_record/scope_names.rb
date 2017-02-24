module ActiveRecord
  module Scoping
    module Named
      module ClassMethods
        attr_reader :scope_names

        alias_method :_scope, :scope

        def scope(name, body, &block)
          @scope_names ||= []

          _scope(name, body, &block)

          @scope_names << name
        end
      end
    end
  end
end
