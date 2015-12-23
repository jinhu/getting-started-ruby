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

class ItemsController < ApplicationController

  PER_PAGE = 30
  @item_type=Item

  def index
    @items, @more = @item_type.query limit: PER_PAGE, cursor: params[:more]
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render  json: @items }
    end
  end

  def new
    @item = @item_type.new
  end

  def show
    @item = @item_type.find params[:id]
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render  json: @item }
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

    @item.creator_id = current_user.id if logged_in?

    if @item.save
      flash[:success] = "Added @item_type"
      redirect_to item_path(@item)
    else
      render :new
    end
  end

  private

  def item_params
    params.require(:item).permit :title, :author, :published_on, :description, :points,
                                 :cover_image
  end

  def convert_published_on_to_date
    if params[:item] && params[:item][:published_on].present?
      params[:item][:published_on] = Time.parse params[:item][:published_on]
    end
  end

end
