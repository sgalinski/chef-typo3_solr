actions :add, :remove

attribute :name, :kind_of => String, :name_attribute => true
attribute :language, :kind_of => String, :default => "english"
attribute :app, :kind_of => String

def initialize(*args)
  super
  @action = :add
end