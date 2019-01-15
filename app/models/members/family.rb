module Members
  class Family < BaseModel
    has_many :members,
             dependent: :nullify

    def destroy_if_empty
      destroy if members.empty?
    end
  end
end
