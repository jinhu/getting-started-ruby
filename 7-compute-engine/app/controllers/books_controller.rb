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

class BooksController < ApplicationController

  PER_PAGE = 10

  def index
    page = params[:page] ? params[:page].to_i : 0

    @books = Book.limit(PER_PAGE).offset(PER_PAGE * page)
    @next_page = page + 1 if @books.count == PER_PAGE
  end

  def new
    @book = Book.new
  end

  def edit
    @book = Book.find params[:id]
  end

  def show
    @book = Book.find params[:id]
  end

  def destroy
    @book = Book.find params[:id]
    @book.destroy
    redirect_to books_path
  end

  def update
    @book = Book.find params[:id]

    if @book.update book_params
      flash[:success] = "Updated Book"
      redirect_to book_path(@book)
    else
      render :edit
    end
  end

  def create
    @book = Book.new book_params

    @book.creator_id = current_user.id if logged_in?

    if @book.save
      flash[:success] = "Added Book"
      redirect_to book_path(@book)
    else
      render :new
    end
  end

  private

  # [START book_params]
  def book_params
    params.require(:book).permit :title, :author, :published_on, :description,
                                 :cover_image
  end
  # [END book_params]

end
