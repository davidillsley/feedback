require 'spec_helper'

describe "Page improvements" do
  it "submits the feedback to the Support API" do
    post "/contact/govuk/page_improvements",
      description: "The title is the wrong colour."

    assert_requested(:post, "#{Plek.current.find('support-api')}/page_improvements")
  end
end
