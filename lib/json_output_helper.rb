module JsonOutputHelper



  # JSON helpers
  # Simple methods for DRYing up and standardizing JSON output
  # ----------------------------------------------------------------------------------------------------
  
  # a nice standard response schema for json
  def json_response(type, hash = {})
    # we require one of these types
    unless [ :ok, :redirect, :error ].include?(type)
      raise "Invalid json response type: #{type}"
    end

    # To keep the structure consistent, we'll build the json 
    # structure with these default properties.
    default_json = { 
      :status => type, 
      :html => nil, 
      :notice => nil, 
      :to => nil
    }.merge(hash)
    return default_json
  end

  # render our standardized json response
  def render_json_response(type, hash = {})
    render :json => json_response(type, hash)
  end
  
  
  
  
  # Response specific helper: For Success and error handling
  # ----------------------------------------------------------------------------------------------------
  
  # helper for success messages (for actions like delete which dont return models)
  def json_success message, hash = {}
    json = {
      :success => true,
      :message => message
    }.merge(hash)
    render :json => json
  end

  # helper for returning failure messages in a common format
  def json_error code, message=nil, metadata={}
    render :json => {
      :error => metadata.merge({
        :message => message || t("api.errors.#{code}"),
        :code => code
      })
    }
  end
  
  
  
  
  # JSON Heper for Models
  # ----------------------------------------------------------------------------------------------------
  
  # a standard way to return models. if they have errors then we return the error message
  # this is a DRY approach to creating and updating and then returning JSON responses
  def json_model model, extra_params={}
    # By default, we use the api_attributes method to return model properties. A custom
    # attributes parameter can be passed also
    if model.errors.empty?
      m = model.send(extra_params[:attributes] || "api_attributes")
      render :json => {"#{model.class.name.downcase.underscore}" => m}.merge(extra_params.except(:attributes))
    else 
      json_error :model_error, model.errors.first.join(' ')
    end
  end

  # a standard way to return an array of models
  # arrays of models are passed back in a data object, this is so we can add things we may need in the future such as pagination
  def json_models models, extra_params={}
    # By default, we use the api_attributes method to return model properties. A custom
    # attributes parameter can be passed also
    if models.present?
      m = models.collect{|model| model.send(extra_params[:attributes] || "api_attributes").merge({:_class_name => model.class.name.downcase.pluralize})}.group_by{|d| d[:_class_name] }
      
      render :json => m.merge(extra_params.except(:attributes))
    else
      render :json => extra_params.except(:attributes)
    end
  end
  
  
  

end

class ActionController::Base
  include JsonOutputHelper
end

