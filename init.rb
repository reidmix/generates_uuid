$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'active_record/generates/uuid'
ActiveRecord::Base.class_eval { include ActiveRecord::Generates::UUID }
