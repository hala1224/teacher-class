class Teacher < ActiveRecord::Base
 has_secure_password

  has_many :categories
  
  has_secure_password


  def slug
    username.downcase.gsub(" ","-")
  end

  def self.find_by_slug(slug)
    Teacher.all.find{|user| user.slug == slug}
  end
end
