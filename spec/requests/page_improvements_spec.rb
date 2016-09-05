require 'spec_helper'
require 'gds_api/test_helpers/support_api'

describe "Page improvements" do
  include GdsApi::TestHelpers::SupportApi

  let(:common_headers) { { "Accept" => "application/json", "Content-Type" => "application/json" } }

  it "submits the feedback to the Support API" do
    stub_any_support_api_call

    post "/contact/govuk/page_improvements",
      { description: "The title is the wrong colour." }.to_json,
      common_headers

    expected_request = a_request(:post, Plek.current.find('support-api') + "/page-improvements")
      .with(body: { "description" => "The title is the wrong colour." })

    expect(expected_request).to have_been_made
  end

  it "responds successfully" do
    stub_any_support_api_call

    post "/contact/govuk/page_improvements",
      { description: "The title is the wrong colour." }.to_json,
      common_headers

    assert_response :success
    expect(response_hash).to include('status' => 'success')
  end

  context "when the Support API isn't available" do
    it "responds with an error" do
      support_api_isnt_available

      post "/contact/govuk/page_improvements",
        { description: "The title is the wrong colour." }.to_json,
        common_headers

      assert_response :error
      expect(response_hash).to include('status' => 'error')
    end
  end

  def response_hash
    JSON.parse(response.body)
  end
end
