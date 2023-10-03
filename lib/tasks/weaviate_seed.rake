task seed_weaviate_database_with_ada_records: :environment do
  weaviate_client = WeaviateClient.create_client
  AdaDataset.parse('ada-export-rently-2023-09-26.csv')

  AdaDataset.records.each do |record|

    document = "### Questions:\n\n"
    record[:questions].each do |question|
      document << '- ' << question << "\n"
    end
    document << "\n### Answer:\n\n" << record[:answer]

    weaviate_client.objects.create(
      class_name: 'Document',
      properties: {
        type: 'questions and answer',
        content: document
      }
    )
  end
end

task delete_all_ada_records_from_weaviate: :environment do
  WeaviateClient.create_client.objects.batch_delete(
    class_name: 'Document',
    where: {
      path: ['type'],
      operator: 'Like',
      valueText: 'questions and answer'
    }
  )
end