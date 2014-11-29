module Trax
  module Model
    module Validators
      extend ::ActiveSupport::Autoload

      autoload :EmailValidator
      autoload :Frozen
      autoload :FutureDate
      autoload :Subdomain
    end
  end
end
