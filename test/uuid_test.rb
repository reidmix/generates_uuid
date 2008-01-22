require 'test/unit'

require 'rubygems'
gem 'activerecord', '>= 1.15.3'
require 'active_record'

require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :mixins_uuid do |t|
      t.column "uuid", :string, :null => false
    end
    create_table :mixins_token do |t|
      t.column "token", :string, :null => false
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Mixin < ActiveRecord::Base
end

class UUIDMixin < Mixin
  generates_uuid

  def self.table_name() "mixins_uuid" end
end

class TokenMixin < Mixin
  generates_uuid :token

  def self.table_name() "mixins_token" end
end

class UUIDTest < Test::Unit::TestCase

  def setup
    setup_db
    (1..4).each { |i| UUIDMixin.create! }
    TokenMixin.create!
  end

  def teardown
    teardown_db
  end
  
  def test_unique
    assert_equal 4, UUIDMixin.find(:all).map { |u| u.uuid }.sort.uniq.size
  end

  def test_uuid_generation
    test_uuid(UUIDMixin.new)
  end
  
  def test_different_field_name
    test_uuid(TokenMixin.new, :token)
  end

  private 
  def test_uuid(mixin, field = :uuid)
    assert_true mixin.respond_to?(field)
    assert_nil mixin.send(field)
    assert_true mixin.save!
    assert_not_equal "", mixin.send(field)
    uuid = UUID.parse(mixin.send(field))
    assert_true uuid.valid?
    assert_false uuid.nil_uuid? 
    assert_equal 1, uuid.version
  end

  private
  def assert_true(result)
    assert result
  end
  
  def assert_false(result)
    assert !result
  end
end
