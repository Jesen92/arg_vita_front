class Ssubcategory < ActiveRecord::Base
  has_many :articles

  has_many :ssubcategory_subcategories
  has_many :subcategories, :through => :ssubcategory_subcategories

  def self.options_for_select
      order('LOWER(title)').map { |e| [e.title, e.id]  }
  end



end
