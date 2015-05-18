class Newsletter::Newsletter < ActiveRecord::Base
  def sent?
    sent.present?
  end
end
