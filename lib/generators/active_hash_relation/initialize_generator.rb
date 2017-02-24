module ActiveHashRelation
  module Generators
    class InitializeGenerator < Rails::Generators::Base
      desc "This generator creates an initializer file at config/initializers"

      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      def create_initializer_file
        template 'active_hash_relation.rb', 'config/initializers/active_hash_relation.rb'
      end
    end
  end
end
