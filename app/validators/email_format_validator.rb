class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value.match? URI::MailTo::EMAIL_REGEXP

    scope = %i[activerecord errors]
    message = options[:message] ||
              I18n.t(
                :invalid,
                scope: scope + [:models, object.model_name.i18n_key,
                                :attributes, :email],
                default: I18n.t(:invalid, scope: scope + %i[attributes email])
              )
    object.errors[attribute] << message
  end
end
