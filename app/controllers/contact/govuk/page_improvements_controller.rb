class Contact::Govuk::PageImprovementsController < ApplicationController
  def create
    Feedback.support_api.create_page_improvement(page_improvements_params)

    render nothing: true
  end

  def page_improvements_params
    params.slice(:description)
  end
end
