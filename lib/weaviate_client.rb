require 'weaviate'

class WeaviateClient
  class << self
    def create_client
      Weaviate::Client.new( url: 'http://weaviate:8080' )
    end

    def query_document(prompt, limit, distance)
      return nil unless prompt.present?

      create_client.query.get(
        class_name: 'Document',
        fields: 'content type',
        near_text: '{ concepts: ["' << prompt << '"], distance: ' << distance.to_s << ' }',
        limit: limit.to_s
      )
    end
  end
end