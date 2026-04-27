class UserSerializer
  include Alba::Resource
  transform_keys :lower_camel

  attributes :id, :email, :name, :created_at
end
