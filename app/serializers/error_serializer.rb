class ErrorSerializer
  #Hand-roll these for now

  def self.format_params_error(message_list, status_code)
    {
      status: status_code,
      message: message_list
    }
  end

end
