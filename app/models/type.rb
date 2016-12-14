class Type < ActiveRecord::Base
  has_many :articles

  def self.options_for_select
    order('LOWER(title)').map { |e| [e.title, e.id] }
  end

end
