
require "gcloud/datastore"

class Item
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :id, :title, :author, :points, :published_on, :description, :image_url,
                :cover_image, :creator_id, :kind


  validates :title, presence: true

  # Return a Gcloud::Datastore::Dataset for the configured dataset.
  # The dataset is used to create, read, update, and delete entity objects.
  def self.dataset
    @dataset ||= Gcloud.datastore(
      Rails.application.config.database_configuration[Rails.env]["dataset_id"]
    )
  end

  # Query Item entities from Cloud Datastore.
  #
  # returns an array of Item query results and a cursor
  # that can be used to query for additional results.
  # [START items_by_creator]
  def self.query options = {}
    query = Gcloud::Datastore::Query.new
    query.kind options[:kind] if options[:kind]
    query.limit options[:limit]   if options[:limit]
    query.cursor options[:cursor] if options[:cursor]

    if options[:creator_id]
      query.where "creator_id", "=", options[:creator_id]
    end
    # [END items_by_creator]

    results = dataset.run query
    items   = results.map {|entity| Item.from_entity entity }

    if options[:limit] && results.size == options[:limit]
      next_cursor = results.cursor
    end

    return items, next_cursor
  end

  def self.from_entity entity
    item = Item.new
    if(["Book", "Game", "Serie", "Movie", "Activity", "Item"].include?entity.key.kind)
      kind = entity.key.kind
      item.id = entity.key.id
      entity.properties.to_hash.each do |name, value|
        item.send "#{name}=", value
      end
    end
    item
  end

  # Lookup Item by ID.  Returns Item or nil.
  def self.find id
    query    = Gcloud::Datastore::Key.new nil, id.to_i
    entities = dataset.lookup query

    from_entity entities.first if entities.any?
  end

  def to_entity
    entity = Gcloud::Datastore::Entity.new
    entity.key = Gcloud::Datastore::Key.new kind, id
    entity["title"]        = title
    entity["author"]       = author               if author.present?
    entity["points"]       = points               if points.present?
    entity["published_on"] = published_on.to_time if published_on.present?
    entity["description"]  = description          if description.present?
    entity["image_url"]    = image_url            if image_url.present?
    entity["creator_id"]   = creator_id           if creator_id.present?
    entity
  end

  def update attributes
    attributes.each do |name, value|
      send "#{name}=", value
    end
    save
  end

  def destroy
    delete_image if image_url.present?

    Item.dataset.delete Gcloud::Datastore::Key.new "Item", id
  end

  def persisted?
    id.present?
  end

  def upload_image
    image = StorageBucket.files.new(
      key: "cover_images/#{id}/#{cover_image.original_filename}",
      body: cover_image.read,
      public: true
    )

    image.save

    self.image_url = image.public_url

    Item.dataset.save to_entity
  end

  def delete_image
    bucket_name = StorageBucket.key
    image_uri   = URI.parse image_url

    if image_uri.host == "#{bucket_name}.storage.googleapis.com"
      # Remove leading forward slash from image path
      # The result will be the image key, eg. "cover_images/:id/:filename"
      image_key = image_uri.path.sub("/", "")
      image     = StorageBucket.files.new key: image_key

      image.destroy
    end
  end

  def update_image
    delete_image if image_url.present?
    upload_image
  end

  # [START enqueue_job]
  include GlobalID::Identification

  def save
    if valid?
      entity = to_entity
      Item.dataset.save entity

      # TODO separate create and save ...
      unless persisted? # just saved
        self.id = entity.key.id
        lookup_item_details
      end
     
      self.id = entity.key.id
      update_image if cover_image.present?
      true
    else
      false
    end
  end

  private

  def lookup_item_details
    if [author, description, published_on, image_url].any? {|attr| attr.blank? }
      LookupItemDetailsJob.perform_later self
    end
  end
  # [END enqueue_job]
end
