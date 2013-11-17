class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, except: [:index, :new, :create]

  def index
    @task = Task.new(user: current_user)
    @tasks = current_user.get_tasks(session[:time_frame], session[:policies], session[:location])
    #logger.debug "all-my-tasks"
    #logger.debug @tasks
  end

  def new
     @task = Task.new(user: current_user)
  end

  def create
    @task = current_user.add_task(task_params[:title], task_params[:content])
    unless @task.errors.any?
      day_check_array = nil
      if params[:daychecks] != nil
        day_check_array = Util.process_days(params[:daychecks])
      end
      time_check_array = nil
      if params[:timechecks] != nil
        time_check_array = Util.process_times(params[:timechecks])
      end
      @task.update_metadata(params[:tags], params[:day_ranges], day_check_array, params[:time_ranges], time_check_array, params[:locations])
      logger.debug "task-creation"
      logger.debug @task.hidden_tag.hidden_day_range.id
      # metadata[:day_range] = [false, true, true, false, false,...]
      # metadata[:time_range] = [false, true, true, ...]
      # metadata[:locations] = [id1, id2, ...]
      # metadata[:tags] = [id1, id2, ...]
    end
    respond_to do |format|
      format.html { redirect_to tasks_path }
      format.js
    end
  end

  def show
  end

  def edit
  end

  def update
    @task.update(task_params)
    @task.update_metadata(nil, params[:metadata])

    # metadata[:day_range] = [false, true, true, false, false,...]
    # metadata[:time_range] = [false, true, true, ...]
    # metadata[:locations] = [id1, id2, ...]
    # metadata[:tags] = [id1, id2, ...]
  end

  def destroy
  end

  # Stores filter policies in session.
  # 'policies' must be a hash. Ignores keys not in 'POLICIES'.
  def update_policies
    params[:policies].each do |k, v| 
      # Ensure that value is boolean with !!
      session[k] = !!v if Task::POLICIES.include?(k)
    end
  end

  # Stores filter time frame in session.
  # 'time_frame' must be in 'TIME_FRAMES'.
  def update_time_frame
    time_frame = params[:time_frame]
    session[:time_frame] = time_frame if Task::TIME_FRAMES.include?(time_frame)
  end

  private

    def set_task
      @task = Task.find_by(id: params[:id])

      # Check that task exists.
      unless @task
        respond_to do |format|
          flash.alert = "Task not found."
          format.js { render js: "window.location.href = '#{home_url}" }
        end
      end 
    end

    # Sanitize params.
    def task_params
      params.require(:task).permit(:title, :content, :important, :long_lasting)
    end
end
