module ApiHelper
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
    elsif !params[:messages].last.present?
      message = "Blank message is not a valid message."
    elsif params[:limit].present? && !params[:limit].to_i&.between?(1, 5)
      message = "Document limit value out of range."
    elsif params[:distance].present? && !params[:distance].to_f&.between?(0.2, 1)
      message = "Vector distance value out of range."
    end

    render(json: { success: false, message: message }, status: :unprocessable_entity) if message
  end
end