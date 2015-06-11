module ActiveHashRelation
  module Helpers
    def model_class_name(resource)
      resource.class.to_s.split('::').first.constantize
    end
  end
end
