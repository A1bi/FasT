class BaseModel < ActiveRecord::Base
  self.abstract_class = true
  
  def self.cache_key
    e = select("COUNT(*) AS count, #{Rails.env.production? ? "UNIX_TIMESTAMP" : ""}(MAX(#{table_name}.updated_at)) AS max").limit(nil).all.first
    max = Rails.env.production? ? e.max_before_type_cast : e.max_before_type_cast.to_datetime.to_i
    [table_name, max, e.count_before_type_cast].join("/")
  end
end
