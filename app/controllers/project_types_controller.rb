class ProjectTypesController < ApplicationController

    def index
        pt = ProjectType.all
        render json: ProjectTypeSerializer.new(pt)
    end

    def show 
        pt = ProjectType.find(params[:id])
        render json: ProjectTypeSerializer.new(pt)
    end 

end
