require 'weaviate'

class WeaviateClient
  class << self
    def create_client
      Weaviate::Client.new( url: 'http://weaviate:8080' )
    end

    def query_document(prompt)
      return nil unless prompt.present?

      create_client.query.get(
        class_name: 'Document',
        fields: 'content type',
        near_text: '{ concepts: ["' << prompt << '"], distance: 0.5 }',
        limit: '1'
      )
    end
  end
end