class CreateVectorDatabaseClass < ActiveRecord::Migration[7.0]
  def up
    weaviate_client = WeaviateClient.create_client

    begin
      if weaviate_client.schema.get(class_name: 'Document') != "Not Found"
        puts "Class Document already exists"
        return
      end

      weaviate_client.schema.create(
        class_name: 'Document',
        description: 'memory documents for rently AI',
        properties: [
          {
            "dataType": ["text"],
            "description": "content of the document",
            "name": "content"
          }, {
            "dataType": ["text"],
            "description": "type of the content",
            "name": "type"
          }
        ],
        )
    rescue => exception
      if weaviate_client.schema.get(class_name: 'Document') != "Not Found"
        weaviate_client.schema.delete(class_name: 'Document')
      end
      raise exception
    end
  end

  def down
    weaviate_client = WeaviateClient.create_client
    if weaviate_client.schema.get(class_name: 'Document') != "Not Found"
      weaviate_client.schema.delete(class_name: 'Document')
    end
  end
end
