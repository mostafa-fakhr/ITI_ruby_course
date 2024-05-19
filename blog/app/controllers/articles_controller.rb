class ArticlesController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update, :destroy]

  def index
    @articles = Article.all
  end

  def show 
    @article = Article.find(params[:id])
  end

  def new 
    @article = Article.new
  end

  def create
    @article = current_user.articles.new(article_params)
    authorize! :create, @article
    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    authorize! :update, @article

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  def report
    @article = Article.find(params[:id])
    @article.increment!(:reports_count)

    if @article.reports_count >= 3
      @article.update(status: "archived")
    end
    redirect_to root_path, notice: "Article reported successfully."
  end

  private
  def article_params
    params.require(:article).permit(:title, :body, :status, :image)
  end
end
