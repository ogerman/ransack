require 'active_support/core_ext'

require 'ransack/configuration'

require 'ransack/adapters'
Ransack::Adapters.require_constants

module Ransack
  extend Configuration
  class UntraversableAssociationError < StandardError; end;

  SUPPORTS_ATTRIBUTE_ALIAS =
  begin
    ActiveRecord::Base.respond_to?(:attribute_aliases)
  rescue NameError
    false
  end
end

Ransack.configure do |config|
  Ransack::Constants::AREL_PREDICATES.each do |name|
    config.add_predicate name, :arel_predicate => name
  end
  if defined? Ransack::ActiveRecordConstants
    Ransack::ActiveRecordConstants::DERIVED_PREDICATES.each do |args|
      config.add_predicate *args, :active_record
    end
  end
  
  if defined? Ransack::MongoidConstants
    Ransack::MongoidConstants::DERIVED_PREDICATES.each do |args|
      config.add_predicate *args, :mongoid
    end
  end
end

require 'ransack/search'
require 'ransack/ransacker'
require 'ransack/helpers'
require 'action_controller'

require 'ransack/translate'

Ransack::Adapters.require_adapter

ActionController::Base.helper Ransack::Helpers::FormHelper
