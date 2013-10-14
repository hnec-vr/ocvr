module ApplicationHelper
  def session_national_id
    session[:nid]["national_id"]
  end

  def session_name
    [session[:nid]["family_name"], session[:nid]["grandfather_name"], session[:nid]["father_name"], session[:nid]["first_name"]].join(" ")
  end
end
