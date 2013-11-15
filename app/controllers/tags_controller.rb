class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_location, except: [:index, :new, :create]
  before_action :check_permissions

  def index
    current_user.get_tasks()

  end

  def new

  end

  def create

  end

  def show

  end

  def edit

  end

  def update

  end

  def destroy

  end

  private

    def set_tag
      @tag = Tag.find_by(id: params[:id])

      # Check that tag exists.
      unless @tag
        respond_to do |format|
          flash.alert = "Tag not found."
          format.js { render js: "window.location.href = '#{home_url}" }
        end
      end 
    end

    # Sanitize params.
    def tag_params
      params.require(:tag).permit(:name)
    end

    def check_permissions
      unless @tag.user == current_user
        respond_to do |format|
          flash.alert = "Forbidden to access tag."
          format.js { render js: "window.location.href = '#{home_url}'" }
        end
      end
    end
end
