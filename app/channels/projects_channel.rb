class ProjectsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "projects"
    stream_from "comments_Project_#{params[:project_id]}" if params[:project_id]
  end
  
  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

