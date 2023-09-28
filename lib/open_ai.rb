class OpenAi
  include HTTParty
  base_uri 'https://api.openai.com/v1'

  @default_model = 'gpt-3.5-turbo'
  @api_key = ENV['OPENAI_APIKEY']
  @default_headers = { headers: { 'Authorization': "Bearer #{@api_key}" } }

  class << self
    attr_writer :api_key, :model

    def create_chat_completion(from:, messages:)
      post('/chat/completions', {
        body: {
          messages: convert_messages(messages, from),
          model: @model || @default_model,
          temperature: 0.1,
        }.to_json,
        headers: { 'Authorization': "Bearer #{@api_key}", 'Content-Type': 'application/json' },
      })
    end

    def upload_file(path:, name:)
      Dir.mkdir('tmp') unless Dir.exist?('tmp')
      File.open("tmp/#{name}", 'wb') do |output|
        File.open(path, 'rb') do |input|
          IO.copy_stream(input, output)
        end
      end

      response = post('/files', {
        body: {
          file: File.open("tmp/#{name}", 'rb'),
          purpose: 'fine-tune'
        },
        **@default_headers
      })

      File.delete("tmp/#{name}")
      response
    end

    def list_files
      get('/files', @default_headers)
    end

    def delete_file(file_id)
      delete("/files/#{file_id}", @default_headers)
    end

    def download_file(file_id)
      Dir.mkdir('tmp') unless Dir.exist?('tmp')
      content = get("/files/#{file_id}/content", @default_headers)

      File.open("tmp/#{file_id}", 'wb') do |file|
        file.write(content)
      end
    end

    def list_jobs
      get('/fine_tuning/jobs', @default_headers)
    end

    def create_fine_tuning_job(file_id:, suffix: nil)
      post('/fine_tuning/jobs', {
        body: {
          training_file: file_id,
          model: "gpt-3.5-turbo",
          suffix: suffix&.split('.')[0][0...18]
        }.to_json,
        headers: { 'Authorization': "Bearer #{@api_key}", 'Content-Type': 'application/json' },
      })
    end

    def cancel_fine_tuning_job(job_id:)
      post("/fine_tuning/jobs/#{job_id}/cancel", @default_headers)
    end

    def delete_model(model)
      delete("/models/#{model}", @default_headers)
    end

    private

    def convert_messages(messages, type)
      conversation_format(messages)
      if type == :fine_tuned
        @model = 'ft:gpt-3.5-turbo-0613:rently-com:final-training:82yHlobN'
        messages.unshift({role: 'system', content: "You are an helpful customer support person working for the 'Rently' company and you should answer the queries asked by customers in the context of Rently."})
      elsif type == :embedded
        @model = 'gpt-3.5-turbo'
        messages.unshift({role: 'system', content: embedding_prompt(messages.last[:content])})
      end
    end

    def conversation_format(arr)
      arr.map!.with_index do |value, index|
        if index.even?
          {role: 'user', content: value}
        else
          {role: 'assistant', content: value}
        end
      end
    end

    def embedding_prompt(prompt)
      document = WeaviateClient.query_document(prompt).first

      if document
        <<~EOL
          You are an helpful customer support agent working for the 'Rently' company. Analyse the following documents which consist of multiple questions having one common answer at the bottom. 
          Based on the analysis, answer the question asked by the user. If you can't find the answer, try to answer based on your knowledge. Do not mention about the document to the user.
  
          #{document['content']}
        EOL
      else
        "You are an helpful customer support person working for the 'Rently' company and you should answer the queries asked by customers in the context of Rently."
      end
    end
  end
end
