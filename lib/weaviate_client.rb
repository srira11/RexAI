require 'weaviate'

class WeaviateClient
  class << self
    def create_client
      Weaviate::Client.new( url: 'http://weaviate:8080' )
    end
  end
end