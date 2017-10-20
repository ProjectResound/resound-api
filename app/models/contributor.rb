class Contributor < ApplicationRecord
  include ActiveModel::Serialization
  include ActiveModel::ForbiddenAttributesProtection
  extend Textacular

  validates :name, presence: true, length: { minimum: 4 }

  before_save :downcase_name

  def self.parse_and_process(contributors)
    contributors_arr = contributors.split(/\s*,\s*/)
    contributors_str = ''
    contributors_arr.each_with_index do |contributor, i|
      contributor.strip!
      contributor_obj = Contributor.find_or_create_by(name: contributor.downcase)
      if i == contributors_arr.size - 1
        contributors_str += contributor_obj.name
      else
        contributors_str += "#{contributor_obj.name}, "
      end
    end
    contributors_str
  end

  private

  def downcase_name
    self.name.downcase!
  end
end
