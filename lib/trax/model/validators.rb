module Trax
  module Model
    module Validators
      extend ::ActiveSupport::Autoload

      autoload :BooleanValidator
      autoload :EmailValidator
      autoload :Frozen
      autoload :FutureDate
      autoload :Subdomain
      autoload :UrlValidator
    end
  end
end
