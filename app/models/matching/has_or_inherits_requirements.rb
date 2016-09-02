# The unwitting consequence of decentralizing the network of requirements was
# that I had to put code in place to avoid inifinitely looping (in two
# different ways). There are a few different ways this code can be improved.
module Matching::HasOrInheritsRequirements
  extend ActiveSupport::Concern

  included do
    def requirements_with_inherited(eager_load = true, ancestors = [])
      me =
        if eager_load
          self.class.eager_load_requirements_with_inherited.find(id)
        else
          self
        end
      me.direct_requirements + me.inherited_requirements(ancestors)
    end
  
    def requirements_for_archive
      requirements_with_inherited.map{|r| r.prepare_for_archive}
    end

    def direct_requirements
      self.class.associations_for_direct_requirements.map {|_| send(_)}.flatten
    end
  
    def inherited_requirements(ancestors)
      ancestry = ancestors + [[self.class, id]]
      self.class.associations_adding_requirements.map do |association|
        Array.wrap(send(association)).map do |record|
          unless ancestry.include? [record.class, record.id]
            record.requirements_with_inherited(false, ancestry)
          end
        end.flatten
      end.flatten
    end
    
    def self.eager_load_requirements_with_inherited
      eager_load(*associations_for_requirements_with_inherited)
    end
  
    def self.associations_for_requirements_with_inherited(ancestors_calls = [])
      inherited = associations_for_inherited_requirements(ancestors_calls)
      associations_for_direct_requirements + (inherited.empty? ? [] : [inherited])
    end
  
    def self.associations_for_inherited_requirements(ancestors_calls)
      Hash[associations_adding_requirements.map do |association|
        [association, associations_for_association_with_requirements(association, ancestors_calls)]
      end.select {|association, children| children}]
    end
  
    def self.associations_for_association_with_requirements(association, ancestors_calls)
      method = :associations_for_requirements_with_inherited
      if association_class(association).respond_to? method
        send_to_association_class(association, method, ancestors_calls)
      else
        raise ":#{association} given as association with requirements for #{self} but #{association_class(association)} is missing #{method} method."
      end
    rescue ClassMethodLoopException => e
      nil
    end
  
    def self.associations_for_direct_requirements
      reflect_on_association(:requirements) ? [:requirements] : []
    end
  
    def self.associations_adding_requirements
      []
    end

    def self.send_to_association_class(association, method, ancestors_calls = [])
      ancestry_calls = ancestors_calls + [[self, method]]
      if ancestry_calls.include? [association_class(association), method]
        raise ClassMethodLoopException.new("A loop through class method calls has been detected when calling #{association_class(association)}.#{method}.")
      else
        association_class(association).send(method, ancestry_calls)
      end
    end

    def self.association_class(association)
      reflect_on_association(association).class_name.constantize
    end
  end

  class ClassMethodLoopException < StandardError; end;
end
