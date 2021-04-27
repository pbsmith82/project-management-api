class StoriesController < ApplicationController
    def index
        if params[:project_id] && project = Project.find_by_id(params[:project_id])
            stories = project.stories
            render json: StorySerializer.new(stories)
          else
            stories = Story.all
            render json: StorySerializer.new(stories)
          end  
    end

    def show 
        story = Story.find(params[:id])
        render json: StorySerializer.new(story)
    end 

    def create
        story = Story.new(story_params)
        if story.save
            render json: StorySerializer.new(story)
        else 
            render json: {error: "Story Couldn't Be Saved!"}
        end 

    end 

    def destroy 
        story = Story.find(params[:id])
        story.destroy 
        render json: {message: "Successfully Deleted Story: #{story.title}!"}
    end 

    def update 
        story = Story.find(params[:id])
        if story.update(story_params)
            render json: StorySerializer.new(story)
        else 
            render json: {error: "Story Couldn't Be Saved!"}
        end
    end 

    private 

    def story_params
        params.require(:story).permit(:title, :status, :description, :acceptance_criteria, :project_id)
    end

end



