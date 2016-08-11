class BaseModel < ActiveRecord::Base
  self.abstract_class = true

  def self.collection_cache_key(collection, timestamp_column)
    [table_name, collection.maximum(timestamp_column).to_i, collection.except(:limit).count].join("/")
  end
end
