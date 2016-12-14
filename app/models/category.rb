class Category < ActiveRecord::Base

  has_many :category_subcategories
  has_many :subcategories, :through => :category_subcategories

  has_many :article_categories
  has_many :articles, :through => :article_categories

  has_many :category_materials
  has_many :materials, :through => :category_materials


  def self.options_for_select
    order('LOWER(title)').map { |e| [e.title, e.id] }
  end


end
