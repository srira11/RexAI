class Api::ChatsController < Api::ApiController
  include ApiHelper
  before_action :doorkeeper_authorize!
  before_action :validate_params
  wrap_parameters false
  def create
    begin
      response = OpenAi.create_chat_completion(params)

      completion = response.dig('choices', 0, 'message', 'content')
      error = response.dig('error', 'message')

      if error
        render(json: { success: false, message: error }, status: :unprocessable_entity) and return
      else
        render(json: { success: true, completion: completion }, status: :ok) and return
      end

    rescue Exception => error
      render(json: { success: false, message: error }, status: :unprocessable_entity)
    end
  end
end
