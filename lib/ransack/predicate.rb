module Ransack
  class Predicate
    attr_reader :name, :arel_predicate, :type, :formatter, :validator,
                :compound, :wants_array

    class << self

      def predicates(orm)
        if orm == :mongoid
          Ransack.mongoid_predicates.merge Ransack.predicates
        elsif orm == :active_record
          Ransack.active_record_predicates.merge Ransack.predicates
        else
          Ransack.predicates
        end
      end

      def names(orm = nil)
        predicates(orm).keys
      end

      def names_by_decreasing_length(orm = nil)
        names(orm).sort { |a, b| b.length <=> a.length }
      end

      def named(name, orm = nil)
        predicates(orm)[name.to_s]
      end

      def detect_and_strip_from_string!(str, orm = nil)
        if p = detect_from_string(str, orm)
          str.sub! /_#{p}$/, ''.freeze
          p
        end
      end

      def detect_from_string(str, orm = nil)
        names_by_decreasing_length(orm).detect { |p| str.end_with?("_#{p}") }
      end

#      def name_from_attribute_name(attribute_name)
#        names_by_decreasing_length.detect {
#          |p| attribute_name.to_s.match(/_#{p}$/)
#        }
#      end

#      def for_attribute_name(attribute_name)
#        self.named(detect_from_string(attribute_name.to_s))
#      end

    end

    def initialize(opts = {})
      @name = opts[:name]
      @arel_predicate = opts[:arel_predicate]
      @type = opts[:type]
      @formatter = opts[:formatter]
      @validator = opts[:validator] ||
        lambda { |v| v.respond_to?(:empty?) ? !v.empty? : !v.nil? }
      @compound = opts[:compound]
      @wants_array = opts.fetch(:wants_array,
        @compound || Constants::IN_NOT_IN.include?(@arel_predicate))
    end

    def eql?(other)
      self.class == other.class &&
      self.name == other.name
    end
    alias :== :eql?

    def hash
      name.hash
    end

    def format(val)
      if formatter
        formatter.call(val)
      else
        val
      end
    end

    def validate(vals, type = @type)
      vals.any? { |v| validator.call(type ? v.cast(type) : v.value) }
    end

  end
end
