class ErrorSerializer
  #Hand-roll these for now

  def self.format_params_error(message_list, status_code)
    {
      status: status_code,
      message: message_list
    }
  end

  def self.format_user_error(message, status_code)
    #This probably could just be combined with above (and rename them to be common)
    {
      status: status_code,
      message: message
    }
  end

end
