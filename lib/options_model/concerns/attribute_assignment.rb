# frozen_string_literal: true

module OptionsModel
  module Concerns
    module AttributeAssignment
      extend ActiveSupport::Concern

      def initialize(attributes = {})
        update_attributes(attributes)
      end

      def initialize_dup(other)
        super

        update_attributes(other)
      end

      def replace(other)
        return unless other

        raise ArgumentError, "#{other} must be respond to `to_h`" unless other.respond_to?(:to_h)

        other.to_h.each do |k, v|
          if respond_to?("#{k}=")
            public_send("#{k}=", v)
          else
            unused_attributes[k] = v
          end
        end
      end

      alias update_attributes replace

      def [](key)
        public_send(key) if respond_to?(key)
      end

      def []=(key, val)
        setter = "#{key}="
        if respond_to?(setter)
          public_send(setter, val)
        else
          unused_attributes[key] = val
        end
      end

      def fetch(key, default = nil)
        raise KeyError, "attribute not found" if self.class.attribute_names.exclude?(key.to_sym) && default.nil? && !block_given?

        value = respond_to?(key) ? public_send(key) : nil
        return value if value

        if default
          default
        elsif block_given?
          yield
        end
      end

      def attributes
        @attributes ||= ActiveSupport::HashWithIndifferentAccess.new
      end

      def nested_attributes
        @nested_attributes ||= ActiveSupport::HashWithIndifferentAccess.new
      end

      def unused_attributes
        @unused_attributes ||= ActiveSupport::HashWithIndifferentAccess.new
      end
    end
  end
end
