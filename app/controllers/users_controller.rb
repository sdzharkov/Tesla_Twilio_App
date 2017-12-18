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

    if !User.exists?(id: id)
      @user = User.new(:id => id, :name => name)
      @user.save
      send_text(@user.to_json, phone_number)
      render json: @user
    else
      response = "User #{id} already exists."
      send_text(response, phone_number)
    end
  end

  def read_user(id, phone_number)
    if User.exists?(id: id)
      @user = User.find(id)
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

    if User.exists?(id: id)
      puts 'User exists'
      @user = User.find(id)
      @user.update(user_params)
      send_text(@user.to_json, phone_number)
      render json: @user
    else
      unless UnsentMessage.exists?(phone_number: phone_number, entry_id: id)
        @unsent_message = UnsentMessage.new(phone_number: phone_number, entry_id: id, entry_body: name)
        @unsent_message.save
      end

      response = "User #{id} does not exist. If you would like to add him, respond with a 'yes', otherwise 'no'."
      send_text(response, phone_number)
    end
  end

  def delete_user(id, phone_number)
    @user = User.find(id)

    if @user
      @user.destroy
      response = "User #{id} destroyed."
      send_text(response, phone_number)
    else
      response = "User #{id} does not exist."
      send_text(response, phone_number)
    end
  end

  def delegate_unsent_messages(request, phone_number)

    if UnsentMessage.exists?(phone_number: phone_number.sub('+', ' '))
      if request == 'yes'
        @entries = UnsentMessage.where(phone_number: phone_number.sub('+', ' '))
        @entries.each do |entry|
          create_user(entry.entry_id, entry.entry_body, phone_number)
          entry.destroy
        end
      else
        @entries = UnsentMessage.where(phone_number: phone_number.sub('+', ' '))
        @entries.each do |entry|
          entry.destroy
        end
      end
    else
      invalid_command(phone_number: phone_number)
    end
  end

  def invalid_command(phone_number)
    response = "Incorrect command. The following commands are permitted: create, read, update, delete. Example:\n ‘create–1234–Nikola Tesla’,\n ‘read–1234’,\n ‘update–1234–Tesla Motors’,\n ‘delete–1234’\n"
    send_text(response, phone_number)
  end

  def text
    phone_number = params[:From]
    body = params.fetch(:Body, "").downcase

    values = body.split("-")
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
        invalid_command(phone_number)
      end
    elsif values.length == 1 and (values[0] == 'yes' or values[0] == 'no')
      delegate_unsent_messages(values[0], phone_number)
    else
      invalid_command(phone_number)
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
