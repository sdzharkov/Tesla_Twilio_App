class CrudChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    # stream_from "trip_#{params[:room]}"
    stream_from "crud_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def create(opts)
    User.create(
        content: opts.fetch('content')
    )
  end
  # def serve
  #   @users = User.all
  #
  #   ActionCable.server.broadcast("trip_#{params[:room]}", {
  #       data: @users
  #   })
  # end
end
