class Api::V1::TalksController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_api_v1_talk, only: [:messages]
  before_action :is_talk_participant?, only: [:messages]

  def index
    page = params[:page] ? params[:page] : 1
    @talks = Talk.includes(:messages)
                 .joins(:property)
                 .where(['properties.user_id = ? or talks.user_id = ?', current_api_v1_user.id, current_api_v1_user.id])
                 .where(active: true)
                 .group('talks.id, messages.created_at, messages.id')
                 .order('messages.created_at DESC')
                 .paginate(page: page, per_page: 8)
  end

  def messages; end

  def archive
    if params[:id]
      set_api_v1_talk
      @talk.update_attribute(:active, false)
    else
      raise 'Without the correct parameters'
    end
  end

  def unarchive
    if params[:id]
      set_api_v1_talk
      @talk.update_attribute(:active, true)
    else
      raise 'Without the correct parameters'
    end
  end

  def create_message
    if params[:id]
      set_api_v1_talk
    elsif params[:property_id]
      @talk = Talk.create(property: Property.find(params[:property_id]), user: current_api_v1_user)
    else
      raise 'Without the correct parameters'
    end
    @talk.messages << Message.create(body: params[:body], user: current_api_v1_user)
    render json: { success: true }, status: 200
  rescue Exception => errors
    render json: errors, status: :unprocessable_entity
  end

  private

  def set_api_v1_talk
    @talk = Talk.find(params['id'])
  end

  def is_talk_participant?
    if (@talk.user != current_api_v1_user) && (@talk.property.user != current_api_v1_user)
      render(json: { message: 'unauthorized' }, status: 401) && return
    end
  end
end
