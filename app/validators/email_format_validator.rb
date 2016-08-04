class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless value =~ /\A([a-z0-9\-_]+\.?)+@([a-z0-9\-]+\.)+[a-z]{2,9}\z/i
      scope = [:activerecord, :errors]
      message = options[:message] ||
        I18n.t(:invalid, scope: scope.flatten.concat([:models, object.class.name.downcase, :attributes, :email]), default:
        I18n.t(:invalid, scope: scope.flatten.concat([:attributes, :email])))
      object.errors[attribute] << message
    end
  end
end
