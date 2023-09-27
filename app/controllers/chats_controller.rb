class ChatsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index

  end

  def create
    render(json: {
      completion: OpenAi.create_chat_completion(messages: params[:messages])
    })
    return
  end
end
