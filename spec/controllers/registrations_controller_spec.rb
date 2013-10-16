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

    shared_examples "toggles captcha" do
      it "should not display captcha after 1st attempt" do
        User.any_instance.stub(:nid_lookup_count => 1)
        test_request.call
        assert_nil assigns(:render_captcha)
      end

      it "should display captcha after 2nd attempt" do
        User.any_instance.stub(:nid_lookup_count => 2)
        test_request.call
        assert_not_nil assigns(:render_captcha)
      end
    end

    describe '/new' do
      it "loads successfully" do
        get :new
        assert_response :success
      end

      it_behaves_like "toggles captcha" do
        let(:test_request) { Proc.new { get :new } }
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
        post :findnid
      end

      context "should validate captcha after 2nd lookup" do
        it "should not validate captcha if 2nd lookup" do
          User.any_instance.stub(:nid_lookup_count => 2)
          ApplicationController.any_instance.stub(:simple_captcha_valid? => false)
          post :findnid
          assert_nil assigns(:captcha_incorrect)
        end

        it "should validate captcha if 3rd lookup" do
          User.any_instance.stub(:nid_lookup_count => 3)
          ApplicationController.any_instance.stub(:simple_captcha_valid? => false)
          post :findnid
          assert_not_nil assigns(:captcha_incorrect)
        end
      end

      describe "validating national id confirmation" do
        it "should rerender form and display message if confirmation fails" do
          post :findnid, :nid => nid, :nid_confirmation => 1
          assert_not_nil assigns(:invalid_confirmation)
          assert_template :new
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

        it_behaves_like "toggles captcha" do
          let(:test_request) { Proc.new { post :findnid, :nid => nid, :nid_confirmation => nid } }
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

        context "if nid is already claimed" do
          it "should redirect to nid claim form" do
            pending
          end
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

      it "assigns user nid" do
        User.any_instance.should_receive(:update_attributes).with(successful_response[:body], :without_protection => true)
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
  end
end
