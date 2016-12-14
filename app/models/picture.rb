class Picture < ActiveRecord::Base
  has_one :article

  belongs_to :article

  belongs_to :single_article

  has_attached_file :image,
                    :styles => {thumb: "300x300>", original: "1000x1000>", gallery: "200x200#", table: "50x50#", index: "175x200#", show: "263x362#", picture: "340x400#", thumbgal: "72x72#"}


  do_not_validate_attachment_file_type :image
end
