#!/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe RegistrationsController do
  it 'requires login' do
    get :new
    assert_redirected_to login_path
  end

  context 'when logged in' do
    let(:user) { create(:verified_user) }
    let(:nid) { successful_response[:body]["national_id"] }
    let(:uri) { "https://stats.ivote.ly/voter/#{nid}" }

    before do
      sign_in(user)

      stub_request(:get, uri).
        to_return(successful_response)
    end

    shared_examples "a new registration" do
      context 'when a users account is suspended' do
        it "redirects to account suspended page" do
          User.any_instance.stub(:suspended? => true)
          test_request.call
          assert_redirected_to suspended_path
        end
      end

      it "redirects to account if voter registration is closed" do
        Date.stub(:today => ::SETTINGS[:voter_registration_deadline]+1.day)
        test_request.call
        assert_redirected_to account_path
      end

      it "redirects to registration form if nid is already set" do
        User.any_instance.stub(:national_id_set? => true)
        test_request.call
        assert_redirected_to edit_registration_path
      end

      it "redirects to account page if registration is already completed" do
        User.any_instance.stub(:national_id_set? => true)
        User.any_instance.stub(:registration_complete? => true)
        test_request.call
        assert_redirected_to account_path
      end
    end

    describe '/new' do
      it "loads successfully" do
        get :new
        assert_response :success
      end

      it "renders captcha if 2 or more nid lookups" do
        User.any_instance.stub(:nid_lookup_count => 2)
        get :new
        assert_not_nil assigns(:render_captcha)
      end

      it "does not render captcha if less than 2 nid lookups" do
        User.any_instance.stub(:nid_lookup_count => 1)
        get :new
        assert_nil assigns(:render_captcha)
      end

      it_behaves_like "a new registration" do
        let(:test_request) { Proc.new { get :new } }
      end
    end

    describe "#rejectnid" do
      before { session[:nid] = successful_response[:body] }

      it "should record rejection in session" do
        post :rejectnid
        session[:nid_rejections].should include nid
      end

      it "should redirect to nid lookup page if 1st rejection" do
        post :rejectnid
        assert_redirected_to new_registration_path
      end

      it "should redirect to wrongnid if 2nd rejection" do
        session[:nid_rejections] = [nid]
        post :rejectnid
        assert_redirected_to wrongnid_registration_path
      end

      it "should not redirect to wrongnid if rejection is for different nid" do
        session[:nid_rejections] = [420]
        post :rejectnid
        assert_redirected_to new_registration_path
      end
    end

    describe "#wrongnid" do
      before { session[:nid] = successful_response[:body] }

      it "should load successfully" do
        get :wrongnid
        assert_response :success
      end
    end

    describe '#findnid' do
      it "should increment nid lookup count" do
        User.any_instance.should_receive(:increment_nid_lookup_count!)
        post :findnid, :nid => nid, :nid_confirmation => nid
      end

      it "should render captcha after 2nd lookup" do
        User.any_instance.stub(:nid_lookup_count => 1)
        post :findnid, :nid => nid, :nid_confirmation => 123
        assert_not_nil assigns(:render_captcha)
      end

      it "should not render captcha before 2nd lookup" do
        User.any_instance.stub(:nid_lookup_count => 0)
        post :findnid, :nid => nid, :nid_confirmation => 123
        assert_nil assigns(:render_captcha)
      end

      context "should validate captcha after 2nd lookup" do
        it "should not validate captcha if 2nd lookup" do
          User.any_instance.stub(:nid_lookup_count => 2)
          ApplicationController.any_instance.stub(:simple_captcha_valid? => false)
          post :findnid, :nid => nid, :nid_confirmation => nid
          assert_nil assigns(:captcha_incorrect)
        end

        it "should validate captcha if 3rd lookup" do
          User.any_instance.stub(:nid_lookup_count => 3)
          ApplicationController.any_instance.stub(:simple_captcha_valid? => false)
          post :findnid, :nid => nid, :nid_confirmation => nid
          assert_not_nil assigns(:captcha_incorrect)
        end
      end

      it "should suspend account on 5th lookup" do
        User.any_instance.stub(:nid_lookup_count => 5)
        User.any_instance.should_receive(:suspend!).and_return(true)
        post :findnid, :nid => nid, :nid_confirmation => nid
        email_deliveries.count.should eq 1
        assert_redirected_to suspended_path
      end

      describe "validating national id and confirmation" do
        context "if confirmation is invalid" do
          it "should display error" do
            post :findnid, :nid => nid, :nid_confirmation => 1
            assert_not_nil assigns(:invalid_nid_confirmation)
            assert_template :new
          end

          it "should not increment nid lookup count" do
            User.any_instance.should_not_receive(:increment_nid_lookup_count!)
            post :findnid, :nid => nid, :nid_confirmation => 1
          end
        end

        context "if nid is invalid length" do
          it "should display error" do
            post :findnid, :nid => 123, :nid_confirmation => 123
            assert_not_nil assigns(:invalid_nid_length)
            assert_template :new
          end

          it "should not increment nid lookup count" do
            User.any_instance.should_not_receive(:increment_nid_lookup_count!)
            post :findnid, :nid => 123, :nid_confirmation => 123
          end
        end
      end

      it "should convert arabic numerals to english numbers" do
          NidApi.should_receive(:get).with("219810371062")
          nid = "٢١٩٨١٠٣٧١٠٦٢"
          post :findnid, :nid => nid, :nid_confirmation => nid
      end

      context "if age 18 or under" do
        before do
          underage_response = successful_response
          underage_response[:body]["birth_date"] = "2000-01-01T00:00:00"

          stub_request(:get, uri).
            to_return(underage_response)

          post :findnid, :nid => nid, :nid_confirmation => nid
        end

        it "rerenders form" do
          assert_template :new
        end

        it "should display error message" do
          assert_not_nil assigns(:not_found)
        end
      end

      context "if nid not found" do
        before do
          NidApi.stub(:get)
          post :findnid, :nid => nid, :nid_confirmation => nid
        end

        it "rerenders form" do
          assert_template :new
        end

        it "should display error message" do
          assert_not_nil assigns(:not_found)
        end
      end

      context "if nid is found" do
        before do
          post :findnid, :nid => nid, :nid_confirmation => nid
        end

        it "should save nid to session" do
          assert_not_nil session[:nid]
          assert_equal session[:nid], assigns(:nid)
        end

        it "should redirect to confirmation screen" do
          assert_redirected_to confirmnid_registration_path
        end
      end

      it_behaves_like "a new registration" do
        let(:test_request) { Proc.new { post :findnid } }
      end
    end

    describe "/confirmnid" do
      it_behaves_like "a new registration" do
        let(:test_request) { Proc.new { get :confirmnid } }
      end
    end

    describe '#setnid' do
      before do
        session[:nid] = successful_response[:body]
      end

      context "if nid is already claimed" do
        it "should redirect to nid reclaim page" do
          existing_user = create(:verified_user, :national_id => nid)
          post :setnid
          assert_redirected_to reclaimnid_registration_path
        end
      end

      it "saves user with nid data set" do
        User.any_instance.should_receive(:update_attributes).with(successful_response[:body], :without_protection => true).and_return(true)
        post :setnid
      end

      it "redirects to edit registration" do
        post :setnid
        assert_redirected_to edit_registration_path
      end

      it_behaves_like "a new registration" do
        let(:test_request) { Proc.new { post :setnid } }
      end
    end

    describe '/reclaimnid' do
      context "when session nid is set" do
        before do
          session[:nid] = successful_response[:body]
        end

        it "loads successfully" do
          get :reclaimnid
          assert_response :success
        end

        it_behaves_like "a new registration" do
          let(:test_request) { Proc.new { get :reclaimnid } }
        end
      end
    end

    describe '/matchnid' do
      let!(:existing_user) do
        create(:verified_user,
          :registry_number => successful_response[:body]["registry_number"],
          :mother_name => successful_response[:body]["mother_name"])
      end

      before do
        session[:nid] = successful_response[:body]
      end

      it "displays form errors if blank fields" do
        post :matchnid
        assert_response :success
        assert_template :reclaimnid
      end

      context "if fields are not blank" do
        it "redirects to nid review page" do
          NidReview.stub(:create!)
          post :matchnid, :registry_number => existing_user.registry_number,
                          :mother_name => "a name"

          assert_redirected_to nidreview_registration_path
        end

        it "should create nid review record" do
          NidReview.should_receive(:create!)
          post :matchnid, :registry_number => existing_user.registry_number,
                          :mother_name => "a name"
        end

        it "should send email verification email" do
          post :matchnid, :registry_number => existing_user.registry_number,
                          :mother_name => "a name"
          email_deliveries.count.should eq 1
        end
      end

      it_behaves_like "a new registration" do
        let(:test_request) { Proc.new { post :matchnid } }
      end
    end

    describe '/nidreview' do
      it "should load successfully" do
        get :nidreview
      end
    end

    describe '/edit' do
      it "redirects to /new if nid not set" do
        get :edit
        assert_redirected_to new_registration_path
      end
    end

    describe '#update' do
      it "redirects to /new if nid not set" do
        put :update, :user => {:constituency_id => 1, :voting_location_id => 1}
        assert_redirected_to new_registration_path
      end

      context "when nid is set" do
        let(:user) { create(:user_with_nid) }
        before { sign_in(user) }

        it "toggles validation" do
          User.any_instance.should_receive(:validate_registration!)
          put :update, :user => {:constituency_id => 1, :voting_location_id => 1}
        end

        it "updates user" do
          User.any_instance.should_receive(:update_attributes)
          put :update, :user => {:constituency_id => 1, :voting_location_id => 1}
        end

        it "re-renders form if validation fails" do
          put :update, :user => {}
          assert_template :edit
        end

        it "redirects to thank you page" do
          put :update, :user => {:constituency_id => 1, :voting_location_id => 1}
          assert_redirected_to end_registration_path
        end
      end
    end

    describe '/end' do
      context "unregistered user" do
        let(:user) { create(:user_with_nid) }
        before { sign_in(user) }

        it "redirects to registration form" do
          get :end
          assert_redirected_to edit_registration_path
        end
      end

      context "registered user" do
        let(:user) { create(:registered_user) }
        before { sign_in(user) }

        it "loads successfully" do
          get :end
          assert_response :success
        end
      end
    end

    describe '/print' do
      context "unregistered user" do
        let(:user) { create(:user_with_nid) }
        before { sign_in(user) }

        it "redirects to registration form" do
          get :print
          assert_redirected_to edit_registration_path
        end
      end

      context "registered user" do
        let(:user) { create(:registered_user) }
        before { sign_in(user) }

        it "loads successfully" do
          get :print
          assert_response :success
        end
      end
    end
  end
end
