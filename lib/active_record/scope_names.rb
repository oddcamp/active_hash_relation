module ActiveRecord
  module Scoping
    module Named
      module ClassMethods
        attr_reader :scope_names

        def scope(name, body, &block)
          @scope_names ||= []
          unless body.respond_to?(:call)
            raise ArgumentError, 'The scope body needs to be callable.'
          end

          if dangerous_class_method?(name)
            raise ArgumentError, "You tried to define a scope named \"#{name}\" " \
              "on the model \"#{self.name}\", but Active Record already defined " \
              "a class method with the same name."
          end

          extension = Module.new(&block) if block

          singleton_class.send(:define_method, name) do |*args|
            scope = all.scoping { body.call(*args) }
            scope = scope.extending(extension) if extension

            scope || all
          end


          @scope_names << name
        end
      end
    end
  end
end
