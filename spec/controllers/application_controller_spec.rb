require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      render :nothing => true
    end
  end

  describe "toggling locale" do
    before { get :index, :locale => "ar" }

    it "captures locale from url param" do
      session[:locale].should eq "ar"
    end

    it "captures locale from url param" do
      I18n.locale.should eq :ar
    end
  end

  describe "setting locale" do
    it "sets locale from session" do
      session[:locale] = "ar"
      get :index
      I18n.locale.should eq :ar
    end
  end
end
