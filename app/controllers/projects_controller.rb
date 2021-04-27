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
        if project.save
            render json: ProjectSerializer.new(project)
        else 
            render json: {error: "Project Couldn't Be Saved!"}
        end 

    end 

    def destroy 
        project = Project.find(params[:id])
        project.destroy 
        render json: {message: "Successfully Deleted Project: #{project.title}!"}
    end 

    def update 
        project = Project.find(params[:id])
        if project.update(project_params)
            render json: ProjectSerializer.new(project)
        else 
            render json: {error: "Project Couldn't Be Saved!"}
        end
    end 

    private 

    def project_params
        params.require(:project).permit(:title, :description, :status, :project_manager, :project_type_id, :target_date)
    end

    def project_create_params
        params.require(:project).permit(:title, :description, :status, :project_manager, :project_type_id, :target_date, :start_date)
    end



end
