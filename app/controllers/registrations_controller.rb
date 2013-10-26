class RegistrationsController < ApplicationController
  before_filter :require_login
  before_filter :ensure_new_registration, :ensure_not_suspended,
                  :only => [:new, :findnid, :confirmnid, :setnid,
                              :reclaimnid, :matchnid, :nidreview]
  before_filter :ensure_national_id_set, :only => [:edit, :update]
  before_filter :ensure_completed_registration,  :only   => [:end, :print]
  before_filter :ensure_voter_registration_open, :except => [:end, :print]

  def new
    @render_captcha = true if current_user.nid_lookup_count >= attempts_allowed_without_captcha
  end

  def findnid
    @render_captcha = true if current_user.nid_lookup_count >= attempts_allowed_without_captcha-1

    unless valid_nid_length?
      @invalid_nid_length = true
      render :new and return
    end

    unless valid_nid_confirmation?
      @invalid_nid_confirmation = true
      render :new and return
    end

    current_user.increment_nid_lookup_count!

    if current_user.nid_lookup_count >= 5
      current_user.suspend!
      I18nMailer.deliver Mailer, :account_suspended, current_user
      redirect_to suspended_path and return
    end

    if validate_captcha? && !simple_captcha_valid?
      @captcha_incorrect = true
      render :new and return
    end

    # api request
    @nid = NidApi.get(params[:nid])

    if @nid
      session[:nid] = @nid
      redirect_to confirmnid_registration_path
    else
      @not_found = true
      render :new
    end
  end

  def confirmnid
  end

  def setnid
    if User.active.find_by_national_id(session[:nid]["national_id"])
      redirect_to reclaimnid_registration_path
    elsif current_user.update_attributes session[:nid], :without_protection => true
      # TODO: delete all unprocessed nid reviews
      redirect_to edit_registration_path
    end
  end

  def rejectnid
    if session[:nid_rejections] && session[:nid_rejections].include?(session[:nid]["national_id"])
      redirect_to wrongnid_registration_path
    else
      if session[:nid_rejections]
        session[:nid_rejections] << session[:nid]["national_id"]
      else
        session[:nid_rejections] = [session[:nid]["national_id"]]
      end

      redirect_to new_registration_path
    end
  end

  def wrongnid
  end

  def reclaimnid
  end

  def matchnid
    if params[:registry_number].present? && params[:mother_name].present?
      NidReview.create! :user => current_user,
                        :registry_number => params[:registry_number],
                        :mother_name => params[:mother_name],
                        :nid_data => session[:nid]
      I18nMailer.deliver Mailer, :nid_claim_received, current_user

      redirect_to nidreview_registration_path
    else
      render :reclaimnid
    end
  end

  def nidreview
  end

  def edit
  end

  def update
    current_user.validate_registration!

    if current_user.update_attributes({
      :constituency_id => params[:user][:constituency_id],
      :voting_location_id => params[:user][:voting_location_id]},
      :without_protection => true)
      redirect_to end_registration_path
    else
      render :edit
    end
  end

  def end
  end

  def print
    render :print, :layout => false
  end

  private

  def attempts_allowed_without_captcha
    2
  end

  def validate_captcha?
    current_user.nid_lookup_count >= attempts_allowed_without_captcha+1
  end

  def valid_nid_length?
    params[:nid].present? && params[:nid].length == 12
  end

  def valid_nid_confirmation?
    params[:nid_confirmation].present? && params[:nid] == params[:nid_confirmation]
  end

  def ensure_completed_registration
    redirect_to edit_registration_path and return unless current_user.registration_complete?
  end

  def ensure_new_registration
    redirect_to account_path and return if current_user.registration_complete?
    redirect_to edit_registration_path and return if current_user.national_id_set?
  end

  def ensure_national_id_set
    redirect_to new_registration_path and return unless current_user.national_id_set?
  end

  def ensure_voter_registration_open
    redirect_to account_path and return if voter_registration_closed?
  end
end
