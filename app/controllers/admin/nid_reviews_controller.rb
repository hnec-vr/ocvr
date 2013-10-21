class Admin::NidReviewsController < Admin::BaseController
  def index
    @nid_reviews = NidReview.order("created_at DESC")
  end

  def approve
    nid_review = NidReview.find(params[:id])
    nid_review.approve!
    Mailer.delay.nid_approval(nid_review)
    redirect_to admin_nid_reviews_path
  end

  def deny
    nid_review = NidReview.find(params[:id])
    nid_review.deny!
    Mailer.delay.nid_denial(nid_review)
    redirect_to admin_nid_reviews_path
  end
end
