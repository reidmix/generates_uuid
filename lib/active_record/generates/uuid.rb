require 'uuidtools'

module ActiveRecord
  module Generates
    module UUID
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def generates_uuid(field = :uuid)
          validates_uniqueness_of field 
          before_validation_on_create do |o|
            # Kernel::UUID is uuidtools, otherwise there's a namespace collision with this module
            o.send("#{ field }=", Kernel::UUID.timestamp_create.to_s)
          end
        end
      end    

    end
  end
end
