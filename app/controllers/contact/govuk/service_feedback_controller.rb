require 'gds_api/base'
class Contact::Govuk::ServiceFeedbackController < ContactController
  private
  def ticket_class
    ServiceFeedback
  end

  def type
    :service_feedback
  end

  def confirm_submission
    redirect_to contact_anonymous_feedback_thankyou_path
  end

  def respond_to_invalid_submission(ticket)
    # for now, ignore just discard invalid submissions
    # because the actual form lives in the "frontend" app,
    # it's not straightforward to re-render the form with
    # the user's original input
    GdsApi::Base.logger = Logger.new("./log/no_ratings_log.txt")
    confirm_submission
  end
end
