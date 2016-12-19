module Validators::CustomValidators
  class MinAge < Grape::Validations::Base
    def validate_param!(attr_name, params)
      return unless params[attr_name]
      return if params[attr_name].class != Date
      unless (params[attr_name] + @option.years) <= Date.today
        raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "must be at least #{@option} years old to register"
      end
    end
  end

  class OneLower < Grape::Validations::Base
    def validate_param!(attr_name, params)
      return unless params[attr_name]
      unless params[attr_name] =~ /[a-z]/
        raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: 'must contain at least 1 lowercase letter'
      end
    end
  end

  class OneUpper < Grape::Validations::Base
    def validate_param!(attr_name, params)
      return unless params[attr_name]
      unless params[attr_name] =~ /[A-Z]/
        raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: 'must contain at least 1 uppercase letter'
      end
    end
  end

  class OneDigitOrSpecialCharacter < Grape::Validations::Base
    def validate_param!(attr_name, params)
      return unless params[attr_name]
      unless params[attr_name] =~ /[0-9]|[^A-Za-z0-9]/
        raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: 'must contain at least 1 digit or special character'
      end
    end
  end

  class MinLength < Grape::Validations::Base
    def validate_param!(attr_name, params)
      return unless params[attr_name]
      unless params[attr_name].length >= @option
        raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "must be at least #{@option} characters long"
      end
    end
  end
end
