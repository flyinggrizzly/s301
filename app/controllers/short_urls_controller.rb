class ShortUrlsController < ApplicationController
  before_action :require_login
  before_action :set_short_url, only: [:show, :edit, :update, :destroy]

  # GET /short_urls
  # GET /short_urls.json
  def index
    @short_urls = ShortUrl.paginate(page: params[:page])
  end

  # GET /short_urls/1
  def show
  end

  # GET /short_urls/new
  def new
    @short_url = ShortUrl.new
  end

  # GET /short_urls/1/edit
  def edit
  end

  # POST /short_urls
  def create
    @short_url = ShortUrl.new(short_url_params)
    if @short_url.save
      flash[:success] = "Short URL '#{@short_url.slug}' (redirecting to #{@short_url.redirect}) was created successfully."
      redirect_to short_urls_path
    else
      render 'new'
    end
  end

  # PATCH/PUT /short_urls/1
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

  # DELETE /short_urls/1
  def destroy
    @short_url = ShortUrl.find(params[:id])
    @short_url.destroy
    flash[:success] = "Short URL '#{@short_url.slug}' has been deleted."
    redirect_to short_urls_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_short_url
    @short_url = ShortUrl.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def short_url_params
    params.require(:short_url).permit(:slug, :redirect)
  end
end
