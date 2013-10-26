module ApplicationHelper
  def session_national_id
    session[:nid]["national_id"]
  end

  def session_name
    [session[:nid]["first_name"], session[:nid]["father_name"], session[:nid]["grandfather_name"], session[:nid]["family_name"]].join(" ")
  end

  def display_password_confirmation_error?
    @user.errors[:password].count == 1 && @user.nonmatching_password_confirmation?
  end

  def constituency_grouped_options
    options = []

    Constituency.all.group_by(&:main_district).each do |district, constituencies|
      options << [district, constituencies.collect {|c| [c.name, c.id]}]
    end

    options
  end
end
