require_relative "../../common/jsonmodel"

module ASpaceExport
  
  @@initialized = false
  
  def self.init            
    @@serializers = {}
    @@models = {}
    Dir.glob(File.dirname(__FILE__) + '/../serializers/*', &method(:load))
    Dir.glob(File.dirname(__FILE__) + '/../models/*', &method(:load))
    @@initialized = true    
  end
  
  def self.initialized?
    @@initialized
  end
  
  # Define or get a serializer
  def self.serializer(name, superclass = ASpaceExport::Serializer, &block)
    if @@serializers.has_key? name and block_given?
      Log.warn("Registered a serializer -- #{name} -- more than once")
    end
    
    unless block_given? or @@initialized
      self.init
    end
    
    if block_given?
      c = Class.new(superclass, &block)
      Object.const_set("#{name.to_s.capitalize}Serializer", c)
      @@serializers[name] = c
      true
    elsif @@serializers[name] == nil
      raise StandardError.new("Can't find a serializer named #{name}")
    else
      @@serializers[name].new
    end
  end 
  
  # Define or get an export model
  def self.model(name, superclass = ASpaceExport::ExportModel, &block)
    if @@models.has_key? name and block_given?
      Log.warn("Registered a model -- #{name} -- more than once")
    end
    
    unless block_given? or @@initialized
      self.init
    end
    
    if block_given?
      c = Class.new(superclass, &block)
      Object.const_set("#{name.to_s.capitalize}ExportModel", c)
      @@models[name] = c
      true
    elsif @@models[name] == nil
      raise StandardError.new("Can't find a model named #{name}")
    else
      @@models[name]
    end
  end 

  # Abstract serializer class
  class Serializer
    
    def initialize
      @repo_id = Thread.current[:repo_id] ||= 1
    end
    
    def repo_id=(id)
      @repo_id = id
    end
    
    def set(instance_variable, value)
      self.instance_variable_set(instance_variable, value)
    end

    # Serializes an ASModel object
    def serialize(object) end  
  end
  
  # Abstract Export Model class
  class ExportModel
    def initialize
    end
    
  end
   
end
      
      