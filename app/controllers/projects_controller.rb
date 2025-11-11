class ProjectsController < ApplicationController
    def index
        projects = Project.all
        render json: ProjectSerializer.new(projects, {include: [:project_type]})
    end

    def show 
        project = Project.find(params[:id])
        render json: ProjectSerializer.new(project)
    end 

    def create
        project = Project.new(project_create_params)
        project.user = current_user
        if project.save
            # Broadcast via Action Cable
            ActionCable.server.broadcast('projects', {
              type: 'project_created',
              project: ProjectSerializer.new(project).serializable_hash
            })
            render json: ProjectSerializer.new(project)
        else 
            render json: {error: project.errors.full_messages}
        end 

    end 

    def destroy 
        project = Project.find(params[:id])
        authorize_user!(project)
        project.destroy 
        # Broadcast via Action Cable
        ActionCable.server.broadcast('projects', {
          type: 'project_deleted',
          project_id: params[:id]
        })
        render json: {message: "Successfully Deleted Project: #{project.title}!"}
    end 

    def update 
        project = Project.find(params[:id])
        authorize_user!(project)
        if project.update(project_params)
            # Broadcast via Action Cable
            ActionCable.server.broadcast('projects', {
              type: 'project_updated',
              project: ProjectSerializer.new(project).serializable_hash
            })
            render json: ProjectSerializer.new(project)
        else 
            render json: {error: project.errors.full_messages}
        end
    end 

    private 

    def project_params
        params.require(:project).permit(:title, :description, :status, :project_manager, :project_type_id, :target_date, :start_date, :tag_list)
    end

    def project_create_params
        params.require(:project).permit(:title, :description, :status, :project_manager, :project_type_id, :target_date, :start_date, :tag_list)
    end



end
