class ArtefactsController < ApplicationController
  before_filter :find_artefact, :only => [:show, :edit]
  before_filter :build_artefact, :only => [:new, :create]

  respond_to :html, :json

  def index
    @artefacts = Artefact.order_by([[:name, :asc]])

    @section = params[:section] || "all"
    if @section != "all"
      @artefacts = @artefacts.where(tag_ids: params[:section])
    end

    respond_with @artefacts
  end

  def show
    respond_with @artefact do |format|
      format.html { redirect_to @artefact.admin_url }
    end
  end

  def new
    redirect_to_show_if_need_met
  end

  def edit
  end

  def create
    @artefact.save
    respond_with @artefact, location: @artefact.admin_url(params.slice(:return_to))
  end

  # NB: We are departing from usual rails conventions here. PUTing a resource
  # will create it if it doesn't exist, rather than the usual 404.
  def update
    begin
      @artefact = Artefact.from_param(params[:id])
      status_to_use = 200
    rescue Mongoid::Errors::DocumentNotFound
      @artefact = Artefact.new(slug: params[:id])
      status_to_use = 201
    end

    parameters_to_use = extract_parameters(params)

    if attempting_to_change_owning_app_via_api?(parameters_to_use)
      respond_with(@artefact, status: 409) and return
    end

    saved = @artefact.update_attributes(parameters_to_use)
    flash[:notice] = saved ? 'Panopticon item updated' : 'Failed to save item'

    if saved and @artefact.live?
      update_router
      update_search
    end

    if saved && params[:commit] == 'Save and continue editing'
      redirect_to edit_artefact_path(@artefact)
    else
      respond_with @artefact, status: status_to_use
    end
  end

  private

    def attempting_to_change_owning_app_via_api?(parameters_to_use)
      request.format.json? && @artefact.persisted? && 
        parameters_to_use['owning_app'] != @artefact.owning_app
    end

    def redirect_to_show_if_need_met
      if params[:artefact] && params[:artefact][:need_id]
        artefact = Artefact.where(need_id: params[:artefact][:need_id]).first
        redirect_to artefact if artefact
      end
    end

    # TODO: This behaviour probably belongs in an Observer
    def update_router
      @router = Router::Client.new(logger: Rails.logger)

      # We assume for now that the application is already registered
      # We also assume we have the same value for owning_app as the router has for app id
      # TODO: Remove these assumptions
      # TODO: What do we do about alternate routes (eg. {slug}.json or things with parts/print/video)?
      # TODO: What do we do about apps that want to claim prefix routes?
      @router.routes.update(application_id: "smartanswers", route_type: :prefix, incoming_path: "/#{@artefact.slug}")
    end

    # TODO: This behaviour probably belongs in an Observer
    def update_search
      structure = normalise_keys(params[:artefact])
      Rummageable.index(rummageable_params(structure))
    end

    # A translation layer because we have inconsistent language.
    # TODO: Make language consistent so this isn't needed any more
    def normalise_keys(structure)
      structure["name"] ||= structure["title"]
      structure["kind"] ||= structure["format"]
      structure["kind"] = 'smart-answer' if structure["kind"] == 'smart_answer'

      structure
    end

    def rummageable_params(structure)
      structure.slice(Rummageable::VALID_KEYS)
    end

    def find_artefact
      @artefact = Artefact.from_param(params[:id])
    end

    def build_artefact
      @artefact = Artefact.new(extract_parameters(params))
    end

    def extract_parameters(params)
      fields_to_update = Artefact.fields.keys + ['sections']

      # TODO: Remove this variance
      parameters_to_use = params[:artefact] || params.slice(*fields_to_update)

      # Strip out the empty submit option for sections
      ['sections'].each do |param|
        param_value = parameters_to_use[param]
        param_value.reject!(&:blank?) if param_value
      end
      parameters_to_use
    end

end
