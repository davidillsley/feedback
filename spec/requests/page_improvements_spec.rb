require 'spec_helper'
require 'gds_api/test_helpers/support_api'

describe "Page improvements" do
  include GdsApi::TestHelpers::SupportApi

  it "submits the feedback to the Support API" do
    stub_any_support_api_call

    post "/contact/govuk/page_improvements", description: "The title is the wrong colour."

    expected_request = a_request(:post, Plek.current.find('support-api') + "/page-improvements")
      .with(body: { "description" => "The title is the wrong colour." })

    expect(expected_request).to have_been_made
  end
end
