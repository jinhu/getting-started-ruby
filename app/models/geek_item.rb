require "gcloud/datastore"


class GeekItem

  include ActiveModel::Model
  include ActiveModel::Validations
  include DatastoreExtensions

  # Book.dataset.connection.http_host = database_config["host"]

  validates :user_id, presence: true
  validates :item_id, presence: true

  attr_accessor :id, :status, :kind, :user_id, :item_id, :item


  def self.dataset
    @dataset ||= Gcloud.datastore(
      Rails.application.config.database_configuration[Rails.env]["dataset_id"]
    )
  end


  def self.query options = {}
    query = Gcloud::Datastore::Query.new
    query.kind "GeekItem"
    query.limit options[:limit]   if options[:limit]
    query.cursor options[:cursor] if options[:cursor]
    query.where "user_id", "=", options[:user_id]
    query.where "status", "=", options[:status]

    results = dataset.run query
    items   = results.map {|entity| GeekItem.from_entity entity }

    if options[:limit] && results.size == options[:limit]
      next_cursor = results.cursor
    end

    return items, next_cursor
  end

  def self.from_entity entity
    geek_item = GeekItem.new
    geek_item.id = entity.key.id
      entity.properties.to_hash.each do |name, value|
        geek_item.send "#{name}=", value
      end
    geek_item.item=Item.find(geek_item.item_id)
    geek_item
  end

  # Lookup Item by ID.  Returns Item or nil.
  def self.find id
    query    = Gcloud::Datastore::Key.new "GeekItem", id.to_i
    entities = dataset.lookup query

    from_entity entities.first if entities.any?
  end

  def to_entity
    entity = Gcloud::Datastore::Entity.new
    entity.key = Gcloud::Datastore::Key.new "GeekItem", id
    entity["user_id"] = user_id
    entity["item_id"] = item_id
    entity["status"]  = status
    entity
  end

  def update attributes
    attributes.each do |name, value|
      send "#{name}=", value
    end
    save
  end

  def destroy
    GeekItem.dataset.delete Gcloud::Datastore::Key.new "GeekItem", id
  end

  def persisted?
    id.present?
  end

  def save
    if valid?
      entity = to_entity
      GeekItem.dataset.save entity
      self.id = entity.key.id
      true
    else
      false
    end
  end

end
