###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# The unwitting consequence of decentralizing the network of services was
# that I had to put code in place to avoid inifinitely looping (in two
# different ways). There are a few different ways this code can be improved.
module HasOrInheritsServices
  extend ActiveSupport::Concern

  included do
    def services_with_inherited(eager_load = true, ancestors = [])
      me =
        if eager_load
          self.class.eager_load_services_with_inherited.find(id)
        else
          self
        end
      me.direct_services + me.inherited_services(ancestors)
    end

    def direct_services
      self.class.associations_for_direct_services.map {|_| send(_)}.flatten
    end

    def inherited_services(ancestors)
      ancestry = ancestors + [[self.class, id]]
      self.class.associations_adding_services.map do |association|
        Array.wrap(send(association)).map do |record|
          unless ancestry.include? [record.class, record.id]
            record.services_with_inherited(false, ancestry)
          end
        end.flatten
      end.flatten
    end

    def services_for_archive
      services_with_inherited.map{|r| r.prepare_for_archive}
    end

    def self.eager_load_services_with_inherited
      eager_load(*associations_for_services_with_inherited)
    end

    def self.associations_for_services_with_inherited(ancestors_calls = [])
      inherited = associations_for_inherited_services(ancestors_calls)
      associations_for_direct_services + (inherited.empty? ? [] : [inherited])
    end

    def self.associations_for_inherited_services(ancestors_calls)
      Hash[associations_adding_services.map do |association|
        [association, associations_for_association_with_services(association, ancestors_calls)]
      end.select {|association, children| children}]
    end

    def self.associations_for_association_with_services(association, ancestors_calls)
      method = :associations_for_services_with_inherited
      if association_class(association).respond_to? method
        send_to_association_class(association, method, ancestors_calls)
      else
        raise ":#{association} given as association with services for #{self} but #{association_class(association)} is missing #{method} method."
      end
    rescue ClassMethodLoopException => e
      nil
    end

    def self.associations_for_direct_services
      reflect_on_association(:services) ? [:services] : []
    end

    def self.associations_adding_services
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
