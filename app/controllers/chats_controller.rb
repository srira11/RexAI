class ChatsController < ApplicationController
  include ApplicationHelper
  before_action :validate_params, only: :create

  def index
  end

  def create
    render(json: {
      success: true,
      completion: markdown(OpenAi.create_chat_completion(from: params[:type].to_sym, messages: params[:messages]))
    }, status: :ok)
  end

  def validate_params
    params[:type] = 'embedded' unless params[:type].present?
    message = nil

    if %w(fine_tuned embedded).exclude? params[:type]
      message = "Invalid type. Only 'fine_tuned' and 'embedded' types are allowed."
    elsif params[:messages].nil?
      message = "'messages' param is required."
    elsif params[:messages].empty?
      message = "'messages' param cannot be empty."
    elsif !params[:messages].is_a? Array
      message = "'messages' param should be an array of messages."
    end

    render(json: { success: false, message: message }, status: :unprocessable_entity) if message
  end
end
