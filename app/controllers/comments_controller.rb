class CommentsController < ApplicationController
  before_action :set_commentable
  
  def index
    comments = @commentable.comments.includes(:user)
    render json: CommentSerializer.new(comments).serializable_hash
  end
  
  def create
    comment = @commentable.comments.build(comment_params)
    comment.user = current_user
    
    if comment.save
      # Broadcast via Action Cable
      ActionCable.server.broadcast("comments_#{@commentable.class.name}_#{@commentable.id}", {
        type: 'new_comment',
        comment: CommentSerializer.new(comment).serializable_hash
      })
      
      render json: CommentSerializer.new(comment).serializable_hash
    else
      render json: { error: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    comment = @commentable.comments.find(params[:id])
    authorize_user!(comment)
    
    comment.destroy
    render json: { message: 'Comment deleted' }
  end
  
  private
  
  def set_commentable
    resource_type = params[:resource_type].classify
    resource_id = params[:resource_id]
    @commentable = resource_type.constantize.find(resource_id)
  end
  
  def comment_params
    params.require(:comment).permit(:content)
  end
end

