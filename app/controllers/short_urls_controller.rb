class ShortUrlsController < ApplicationController
  before_action :require_login, except: [:search, :index, :show]
  before_action :set_short_url, only: [:show, :edit, :update, :destroy]

  def search
    search_by_type(params)
  end

  def index
    @short_urls = ShortUrl.paginate(page: params[:page])
  end

  def show
  end

  def new
    @short_url = ShortUrl.new
  end

  def edit
  end

  def create
    @short_url = ShortUrl.new(short_url_params)
    if @short_url.save
      flash[:success] = "Short URL '#{@short_url.slug}' (redirecting to #{@short_url.redirect}) was created successfully."
      redirect_to short_urls_path
    else
      render 'new'
    end
  end

  def update
    if @short_url.update(short_url_params)
      flash[:success] = "Short URL '#{@short_url.slug}' (redirecting to #{@short_url.redirect}) was updated successfully."
      redirect_to short_urls_path
    else
      render 'edit'
    end
  end

  def delete
    @short_url = ShortUrl.find(params[:id])
  end

  def destroy
    @short_url.destroy
    flash[:success] = "Short URL '#{@short_url.slug}' has been deleted."
    redirect_to short_urls_path
  end

  private

  def search_by_type(search_params)
    if search_params[:search]
      @short_urls = ShortUrl.search(search_params[:search][0]).order('slug ASC')
    elsif search_params[:reverse_search]
      @short_urls = ShortUrl.reverse_search(search_params[:reverse_search][0]).order('slug ASC')
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_short_url
    @short_url = ShortUrl.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def short_url_params
    params.require(:short_url).permit(:slug, :redirect)
  end
end
