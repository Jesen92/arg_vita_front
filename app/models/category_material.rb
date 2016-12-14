class CategoryMaterial < ActiveRecord::Base
  belongs_to :category
  belongs_to :material
end
