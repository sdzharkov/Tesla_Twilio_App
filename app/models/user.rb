class User < ApplicationRecord
  after_commit do
    CrudMessageJob.perform_now(self)
  end
end
