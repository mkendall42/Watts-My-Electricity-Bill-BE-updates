class ApplicationController < ActionController::API
  #These make the most sense in the parent class, given their frequent usage
  #NOTE: these exceptions are captured in middleware BEFORE here; for now, this doesn't do anything (even if it should)
  rescue_from ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished, with: :handle_database_errors

  protected
  
  def handle_database_errors(exception)
    render json: { status: :service_unavailable, message: "Database connection error: #{exception.error_message}" }, status: :service_unavailable
  end
end
