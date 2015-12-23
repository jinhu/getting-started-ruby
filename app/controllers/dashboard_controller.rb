
class DashboardController < ApplicationController


  PER_PAGE = 100

  before_filter :login_required, except: :index

  def index

  end
  def show
      @items, @more = Item.query creator_id: current_user.id,
                               limit: PER_PAGE,
                               cursor: params[:more]
  end

  private

  def login_required
    redirect_to :login unless logged_in?
  end

end
