class ProjectsController < ApplicationController
    def index
        projects = Project.all
        render json: ProjectSerializer.new(projects)
    end

    def show 
        project = Project.find(params[:id])
        render json: ProjectSerializer.new(project)
    end 

#     def create
#         item = Item.new(item_params)
#         if item.save
#             render json: ItemSerializer.new(item)
#         else 
#             render json: {error: "oops"}
#         end 

#     end 

#     def destroy 
#         item = Item.find(params[:id])
#         item.destroy 
#         render json: {message: "successfully deleted #{item.name}"}
#     end 

    def update 
        project = Project.find(params[:id])
        if project.update(project_params)
            render json: ProjectSerializer.new(project)
        else 
            render json: {error: "could not save"}
        end
    end 

    private 

    def project_params
        params.require(:project).permit(:title, :description, :status, :project_manager, :project_type_id, :target_date)
    end

# end



end
