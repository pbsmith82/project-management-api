class AttachmentsController < ApplicationController
  def create
    resource_type = params[:resource_type].classify
    resource_id = params[:resource_id]
    resource = resource_type.constantize.find(resource_id)
    
    authorize_user!(resource)
    
    if params[:files].present?
      params[:files].each do |file|
        resource.attachments.attach(file)
      end
      render json: { message: 'Files uploaded successfully' }
    else
      render json: { error: 'No files provided' }, status: :unprocessable_entity
    end
  end
  
  def destroy
    resource_type = params[:resource_type].classify
    resource_id = params[:resource_id]
    resource = resource_type.constantize.find(resource_id)
    
    authorize_user!(resource)
    
    attachment = resource.attachments.find(params[:id])
    attachment.purge
    render json: { message: 'File deleted' }
  end
end

