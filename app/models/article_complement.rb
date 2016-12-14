class ArticleComplement < ActiveRecord::Base
  belongs_to :single_article
  belongs_to :complement
end
