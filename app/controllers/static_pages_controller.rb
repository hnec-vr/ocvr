class StaticPagesController < ApplicationController
  def start
  end

  def nonid
  end

  def faq
    @body_id = 'faq'
  end

  def confirm
  end
end
