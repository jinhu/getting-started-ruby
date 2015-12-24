class BooksController < ApplicationController

  PER_PAGE = 10

  def index
    @books, @more = Book.query limit: PER_PAGE, cursor: params[:more]
  end

  def new
    @book = Book.new
  end

  def show
    @book = Book.find params[:id]
  end

  def edit
    @book = Book.find params[:id]
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

  def destroy
    @book = Book.find params[:id]
    @book.destroy
    redirect_to books_path
  end

  before_filter :convert_published_on_to_date

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

  def book_params
    params.require(:book).permit :title, :author, :published_on, :description,
                                 :cover_image
  end

  def convert_published_on_to_date
    if params[:book] && params[:book][:published_on].present?
      params[:book][:published_on] = Time.parse params[:book][:published_on]
    end
  end

end
