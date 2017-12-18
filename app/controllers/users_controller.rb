class UsersController < ApplicationController
  # skip_before_action :verify_authenticity_token
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  def create_user(id, name, phone_number)
    @user = User.new(:id => id, :name => name)

    if !User.exists?(:id => id)
      @user.save
      send_text(@user.to_json, phone_number)
      render json: @user
    else
      response = "User #{id} already exists."
      send_text(response, phone_number)
    end
  end

  def read_user(id, phone_number)
    @user = User.find(id)
    puts @user
    if @user
      send_text(@user.to_json, phone_number)
      render json: @user
    else
      response = "This user does not exist."
      send_text(response, phone_number)
    end
  end

  def update_user(id, name, phone_number)
    user_params = {
        id: id,
        name: name
    }

    @user = User.find(id)
    if @user.update(user_params)
      send_text(@user.to_json, phone_number)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def delete_user(id, phone_number)
    @user = User.find(id)

    if @user
      @user.destroy
      response = "User #{id} destroyed."
      send_text(response, phone_number)
    else
      response = "This user does not exist."
      send_text(response, phone_number)
    end
  end

  def text
    puts params
    phone_number = params[:From]
    body = params.fetch(:Body, "").downcase

    values = body.split("-")
    puts values
    if values.length > 1
      case values[0]
      when "create"
        create_user(values[1], values[2], phone_number)
      when "read"
        read_user(values[1], phone_number)
      when "update"
        update_user(values[1], values[2], phone_number)
      when "delete"
        delete_user(values[1], phone_number)
      else
        response = "Incorrect command. Please insert the commands: create, read, update, delete"
        send_text(response, phone_number)
      end
    else
      response = "Incorrect format."
      send_text(response, phone_number)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:id, :name)
    end

    def send_text(body, phone_number)
      @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
      @client.api.account.messages.create(
          from: ENV["TWILIO_NUMBER"],
          to: phone_number,
          body: body
      )
    end
end
