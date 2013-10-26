class Admin::NidReviewsController < Admin::BaseController
  def index
    @nid_reviews = NidReview.order("created_at DESC")
  end

  def approve
    nid_review = NidReview.find(params[:id])
    nid_review.approve!
    I18nMailer.deliver Mailer, :nid_approval, nid_review.user

    redirect_to admin_nid_reviews_path
  end

  def deny
    nid_review = NidReview.find(params[:id])
    nid_review.deny!
    I18nMailer.deliver Mailer, :nid_denial, nid_review.user

    redirect_to admin_nid_reviews_path
  end
end
