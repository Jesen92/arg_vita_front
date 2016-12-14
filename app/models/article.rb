class Article < ActiveRecord::Base

  has_many :carts_articles
  has_many :shopping_carts, :through => :carts_articles

  has_many :article_categories
  has_many :categories, :through => :article_categories

  has_many :related_articles
  has_many :related_articles, :through => :related_articles

  belongs_to :material
  belongs_to :subcategory
  belongs_to :ssubcategory

  belongs_to :color
  belongs_to :type

  has_many :past_purchases
  has_many :users, :through => :past_purchases

  belongs_to :picture

  has_many :coupons

  has_many :single_articles
  accepts_nested_attributes_for :single_articles, allow_destroy: true

  has_many :pictures, :dependent => :destroy

  attr_accessor :color


  def provjera
    @article= Article.all
    @article.each do |article|
      if article.start_date != nil && article.end_date != nil
        if DateTime.now >= article.start_date && DateTime.now < article.end_date
          article.on_discount = true
          article.save
        elsif DateTime.now > article.end_date
          article.on_discount = false
          article.save
        end
      end
    end
  end





  #filterrific
  filterrific(
      default_filter_params: { sorted_by: 'created_at_desc' },
      available_filters: [
          :sorted_by,
          :search_query,
          :with_material_id,
          :with_category_id,
          :with_cost_gte,
          :with_created_at_gte,
          :min_cost,
          :max_cost,
          :with_subcategory_id,
          :with_ssubcategory_id,
          :with_color_id,
          :with_type_id
      ]
  )


  # define ActiveRecord scopes for
  # :search_query, :sorted_by, :with_country_id, and :with_created_at_gte

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^cost_/

        order("articles.cost #{ direction }")
      when /^created_at_/

        order("articles.created_at #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }




  scope :with_category_id, lambda { |category_ids|
    #where(category_id: [*category_ids])

    # get a reference to the join table
    art_cat = ArticleCategory.arel_table
    # get a reference to the filtered table
    articles = Article.arel_table
    # let AREL generate a complex SQL query
    where(
        ArticleCategory \
                              .where(art_cat[:article_id].eq(articles[:id])) \
                              .where(art_cat[:category_id].in([*category_ids].map(&:to_i))) \
                              .exists
    )
  }


  scope :with_color_id, lambda { |color_ids|
    where(color_id: [*color_ids])
  }

  scope :with_type_id, lambda { |type_ids|
    where(type_id: [*type_ids])
  }

# scopovi za podkategorije i podpodkategorije
  scope :with_subcategory_id, lambda { |subcategory_ids|
    where(subcategory_id: [*subcategory_ids])
  }

  scope :with_ssubcategory_id, lambda { |ssubcategory_ids|
    where(ssubcategory_id: [*ssubcategory_ids])
  }

##################################################################



 #scopovi za cijene
  scope :with_cost_gte, lambda { |ref_int|
    where(cost: [*ref_int])
  }


  scope :max_cost, lambda { |ref_int|


    where("articles.cost < ?", [*ref_int])
  }

  scope :min_cost, lambda { |ref_int|
    min, max = ref_int.to_s.split(';')

    mmin = min.delete('"[\/]')
    mmax = max.delete('"[\/]')
    puts "minimum je #{min.delete('"[\/]')}"
    puts "maximum je #{max.delete('"[\/]')}"

    if mmin != mmax
      where("articles.cost >= ? AND articles.cost <= ?",  mmin, mmax)
    end

  }

######################################################



 # scope :with_category_id, lambda { |category_ids|
  #  where(category_id: [*category_ids])
  #}

  scope :with_material_id, lambda { |material_ids|
    where(material_id: [*material_ids])
  }

  scope :with_created_at_gte, lambda { |ref_date|
    where(created_at: [*ref_date])
  }

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
        "(LOWER(articles.title) LIKE ? OR LOWER(articles.title_eng) LIKE ? OR LOWER(articles.code) LIKE ?)", "%#{terms}%", "%#{terms}%", "%#{terms}%"
    )
  }

  def self.options_for_sorted_by
    [
        ['Cijeni (od najmanje)', 'cost_asc'],
        ['Cijeni (od najvise)', 'cost_desc'],
        ['Proizvodima(novi prvi)', 'created_at_desc'],
        ['Proizvodima(stari prvi)', 'created_at_asc']

    ]
  end
end

