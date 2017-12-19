class CrudMessageJob < ApplicationJob
  queue_as :default

  def perform(users)
    @users = User.all
    puts @users, users
    ActionCable
        .server
        .broadcast('crud_channel',
                   'users': @users)
  end
end
