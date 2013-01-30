actions :add, :remove

attribute :name, :kind_of => String, :name_attribute => true
attribute :solr, :kind_of => String, :default => '3.6.2'
attribute :extension, :kind_of => String, :default => '2.8'
attribute :plugin, :kind_of => String, :default => '1.2.0'
attribute :languages, :kind_of => Array, :default => %w{ english }

def initialize(*args)
  super
  @action = :add
end