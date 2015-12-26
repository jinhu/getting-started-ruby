module DatastoreExtensions

  def self.included base
    base.send :extend, ClassMethods
  end

  # def reload
  #   book = Item.find id
  #   self.title        = book.title
  #   self.author       = book.author
  #   self.published_on = book.published_on
  #   self.description  = book.description
  #   self.image_url    = book.image_url
  #   book
  # end

  module ClassMethods

    def all
      items = []

      query = Gcloud::Datastore::Query.new#.kind  self.class.name

      loop do
        results = dataset.run query

        if results.empty?
          break
        else
          results.each {|entity| items << from_entity(entity) }
          query.cursor results.cursor
          results = dataset.run query
        end
      end

      items
    end

    def first
      all.first
    end

    def count
      all.length
    end

    def delete_all
      query = Gcloud::Datastore::Query.new.kind self.class.name
      loop do
        books = dataset.run query
        if books.empty?
          break
        else
          dataset.delete *books
        end
      end
    end

    def exists? id
      find(id).present?
    end

    def create attributes = nil
      item = self.new attributes
      item.save
      item
    end

    def create! attributes = nil
      geek_item = GeekItem.new attributes
      raise "GeekItem save failed" unless geek_item.save
      geek_item
    end
  end
end
