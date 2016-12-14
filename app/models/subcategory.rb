class Subcategory < ActiveRecord::Base
  has_many :articles

  has_many :category_subcategories
  has_many :categories, :through => :category_subcategories

  has_many :ssubcategory_subcategories
  has_many :ssubcategories, :through => :ssubcategory_subcategories

  has_attached_file :avatar,
                    :styles => {thumb: "300x300#", table: "26x26#", index: "350x250#"}

  do_not_validate_attachment_file_type :avatar

  filterrific(
      available_filters: [
          :search_query
      ]
  )

  def self.options_for_select
    order('LOWER(title)').map { |e| [e.title, e.id] }
  end

  scope :search_query, lambda { |query|

    return nil  if query.blank?


    terms = query.downcase

    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s

    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conds = 1
    where(
        "(LOWER(subcategories.title) LIKE ? OR LOWER(subcategories.title_eng) LIKE ?)", "%#{terms}%", "%#{terms}%"
    )
  }

end
