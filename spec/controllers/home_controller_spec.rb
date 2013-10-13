require 'spec_helper'

describe HomeController do
  describe 'viewing the home page' do
    it { assert_response 200 }
  end
end
