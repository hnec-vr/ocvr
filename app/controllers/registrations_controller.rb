class RegistrationsController < ApplicationController
  before_filter :require_login
  before_filter :ensure_new_registration, :only => [:new, :findnid, :confirmnid, :setnid]
  before_filter :ensure_national_id_set, :only => [:edit, :update]
  before_filter :ensure_completed_registration, :only => :end

  def new
    @render_captcha = true if render_captcha?
  end

  def findnid
    current_user.increment_nid_lookup_count!

    @render_captcha = true if render_captcha?

    if validate_captcha? && !simple_captcha_valid?
      @captcha_incorrect = true
      render :new and return
    end

    unless nid_fields_exist_and_match?
      @invalid_confirmation = true
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
    current_user.update_attributes session[:nid]

    redirect_to edit_registration_path
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

  def edit
  end

  def update
    current_user.validate_registration!

    if current_user.update_attributes(
      :constituency_id => params[:user][:constituency_id],
      :voting_location_id => params[:user][:voting_location_id],
      :registration_submission_count => current_user.registration_submission_count+1)
      redirect_to end_registration_path
    else
      render :edit
    end
  end

  def end
  end

  private

  def attempts_allowed_without_captcha
    2
  end

  def validate_captcha?
    current_user.nid_lookup_count >= attempts_allowed_without_captcha+1
  end

  def render_captcha?
    current_user.nid_lookup_count >= attempts_allowed_without_captcha
  end

  def nid_fields_exist_and_match?
    params[:nid].present? && params[:nid_confirmation].present? && params[:nid] == params[:nid_confirmation]
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
end
