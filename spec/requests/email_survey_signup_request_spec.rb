require 'rails_helper'

RSpec.describe "Email survey sign-up request", type: :request do
  include EmailSurveyHelpers
  before do
    stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/email')
      .to_return(status: 200, body: '{}')

    stub_surveys_data(create_education_email_survey)
  end

  context 'for a standard HTML request' do
    it "shows the standard thank you message on success" do
      submit_email_survey_sign_up

      expect(response).to redirect_to(contact_anonymous_feedback_thankyou_path)
      get contact_anonymous_feedback_thankyou_path

      expect(response.body).to include("Thank you for your feedback.")
    end

    it "should accept invalid submissions, just not do anything with them (because the form itself lives
      in the static app and re-rendering it with the user's signup isn't straightforward" do
      submit_email_survey_sign_up(params: {})

      expect(response).to redirect_to(contact_anonymous_feedback_thankyou_path)
      get contact_anonymous_feedback_thankyou_path

      expect(response.body).to include("Thank you for your feedback.")
    end

    it "should handle the GOV.UK notify service failing" do
      stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/email')
        .to_return(status: 403, body: '{"errors":[{"error":"forbidden","message":"You cannot do this!"}]}')

      submit_email_survey_sign_up

      # the user should see the standard GOV.UK 503 page
      expect(response.code).to eq("503")
    end
  end

  context 'for an AJAX request' do
    it "responds inline with a 200 ok success message" do
      submit_email_survey_sign_up as_xhr: true

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json")
      expect(JSON.parse(response.body)).to eq({ "message" => "email survey sign up success"})
    end

    it "responds with a 422 failure for invalid submissions" do
      submit_email_survey_sign_up as_xhr: true, params: {}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq("application/json")
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key "message"
      expect(json_response["message"]).to eq "email survey sign up failure"
      expect(json_response).to have_key "errors"
    end

    it "should handle the GOV.UK notify service failing" do
      stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/email')
        .to_return(status: 403, body: '{"errors":[{"error":403,"message":"forbidden"}]}')

      submit_email_survey_sign_up as_xhr: true

      expect(response).to have_http_status(:service_unavailable)
      expect(response.content_type).to eq("application/json")
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key "message"
      expect(json_response["message"]).to eq "email survey sign up failure"
      expect(json_response).to have_key "errors"
    end
  end

  context 'for a JS request' do
    it "responds inline with a 200 ok success message" do
      submit_email_survey_sign_up as_js: true

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json")
      expect(JSON.parse(response.body)).to eq({ "message" => "email survey sign up success"})
    end

    it "responds with a 422 failure for invalid submissions" do
      submit_email_survey_sign_up as_js: true, params: {}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq("application/json")
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key "message"
      expect(json_response["message"]).to eq "email survey sign up failure"
      expect(json_response).to have_key "errors"
    end

    it "should handle the GOV.UK notify service failing" do
      stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/email')
        .to_return(status: 403, body: '{"errors":[{"error":403,"message":"forbidden"}]}')

      submit_email_survey_sign_up as_js: true

      expect(response).to have_http_status(:service_unavailable)
      expect(response.content_type).to eq("application/json")
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key "message"
      expect(json_response["message"]).to eq "email survey sign up failure"
      expect(json_response).to have_key "errors"
    end
  end

  it "sends an email to the supplied email address using GOV.UK notify" do
    submit_email_survey_sign_up

    notify_request = a_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/email')
      .with { |request|
        json_payload = JSON.parse(request.body)
        (json_payload["email_address"] == "i_like_surveys@example.com") &&
          (json_payload["personalisation"]["survey_url"] == "http://survey.example.com/1?c=%2Fdone%2Fsome-transaction")
      }
    expect(notify_request).to have_been_requested
  end

  def submit_email_survey_sign_up(params: valid_params, headers: {}, as_xhr: false, as_js: false)
    args = ["/contact/govuk/email-survey-signup", params, headers]
    if as_xhr
      xhr(:post, *args)
    else
      args.first << '.js' if as_js
      post *args
    end
  end

  def valid_params
    {
      email_survey_signup: {
        survey_id: 'education_email_survey',
        survey_source: '/done/some-transaction',
        email_address: "i_like_surveys@example.com",
      }
    }
  end
end
