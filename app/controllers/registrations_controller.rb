class RegistrationsController < ApplicationController
  before_filter :require_login
  before_filter :ensure_new_registration, :only => [:new, :findnid, :confirmnid, :setnid]

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

  def ensure_new_registration
    redirect_to account_path and return if current_user.registration_complete?
    redirect_to edit_registration_path and return if current_user.national_id_set?
  end
end
