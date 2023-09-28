class ChatsController < ApplicationController
  include ApplicationHelper
  include ApiHelper
  before_action :validate_params, only: :create
  before_action :authenticate_user!

  def index
  end

  def create
    response = OpenAi.create_chat_completion(from: params[:type].to_sym, messages: params[:messages])

    completion = response.dig('choices', 0, 'message', 'content')
    error = response.dig('error', 'message')

    if error
      render(json: { success: false, message: error }, status: :unprocessable_entity) and return
    else
      render(json: { success: true, completion: markdown_to_html(completion) }, status: :ok)
    end
  end
end
