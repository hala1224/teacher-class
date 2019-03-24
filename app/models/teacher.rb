class Teacher < ActiveRecord::Base
 has_secure_password

  has_many :categories



  def slug
    name.downcase.gsub(" ","-")
  end

  def self.find_by_slug(slug)
    Teacher.all.find{|teacher| teacher.slug == slug}
  end
end
