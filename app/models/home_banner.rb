class HomeBanner < ActiveRecord::Base

  has_attached_file :image,
                    :styles => {bann: "1600x650#"}

  do_not_validate_attachment_file_type :image
end
