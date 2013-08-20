class BaseModel < ActiveRecord::Base
  self.abstract_class = true
  
  def self.cache_key
    e = except(:limit, :order).select("COUNT(*) AS count, #{Rails.env.production? ? "UNIX_TIMESTAMP" : ""}(MAX(#{table_name}.updated_at)) AS max").all.first
    e['max'] = e['max'] ? (Rails.env.production? ? e['max'] : e['max'].to_datetime.to_i) : 0
    [table_name, e['max'], e['count']].join("/")
  end
end
