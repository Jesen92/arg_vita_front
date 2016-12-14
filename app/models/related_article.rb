class RelatedArticle < ActiveRecord::Base
  belongs_to :article
  belongs_to :related_article, :class_name => "Article", :foreign_key => "related_article_id"
end
