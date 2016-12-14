class ShopBanner < ActiveRecord::Base

  has_attached_file :image,
                    :styles => {bann: "1600x300#", bannsm: "1600x150#" }

  do_not_validate_attachment_file_type :image

end
