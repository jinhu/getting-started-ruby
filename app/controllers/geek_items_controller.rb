# Copyright 2015, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class GeekItemsController < ApplicationController
  before_action :authenticate
  def authenticate
    redirect_to :login if not current_user
  end

  PER_PAGE = 10

  def initialize
    super
    @item_type=GeekItem

  end

  def index
    status = params[:status] || "to_do"
    @items, @more = @item_type.query limit: PER_PAGE, cursor: params[:more], status: status, user_id: current_user.id
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render  json: @items }
    end
  end


  def new
    @item = @item_type.new
  end

  def show
    if params[:id]=="create_all"
      Item.all('Game').each do |item|
        GeekItem.create user_id: current_user.id, status: "to_do", item_id: item.id

      end
      render text: "done"
    elsif params[:status]
      @item = @item_type.find params[:id]
      @item.status =params[:status].strip
      @item.save
      format.html # show.html.erb
      format.json  { render  json: @item }

    else
    @item = @item_type.find params[:id]
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render  json: @item }
    end
    end

  end

  def edit
    @item = @item_type.find params[:id]
  end

  def update
    @item = @item_type.find params[:id]

    if @item_type.update item_params
      flash[:success] = "Updated Book"
      redirect_to book_path(@book)
    else
      render :edit
    end
  end

  def destroy
    @item = @item_type.find params[:id]
    @item_type.destroy
    redirect_to books_path
  end

  before_filter :convert_published_on_to_date

  def create
    @item = @item_type.new item_params

    @item.user_id = current_user.id

    if @item.save
      flash[:success] = "Added @item_type"
      redirect_to geek_item_path(@item)
    else
      render :new
    end
  end


  private

  def item_params
    params.require(:geek_item).permit :item_id, :status, :kind, :description
  end

  def convert_published_on_to_date
    if params[:item] && params[:item][:published_on].present?
      params[:item][:published_on] = Time.parse params[:item][:published_on]
    end
  end

end
