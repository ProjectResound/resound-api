# frozen_string_literal: true

class AudioSearchEngine < ActiveRecord::Base
  extend Textacular

  belongs_to :searchable, polymorphic: true

  self.primary_key = :searchable_id

  def self.search(query)
    if ActiveRecord::Base.connection.instance_values['config'][:adapter] ==
       'mysql2'
      query.downcase!
      AudioSearchEngine.where('lower(title) LIKE (?)', "%#{query}%")
                       .or(
                         Audio.where('lower(filename) LIKE (?)', "%#{query}%")
                       )
                       .or(
                         Audio.where('lower(tags) LIKE (?)', "%#{query}%")
                       )
                       .or(
                         Audio.where('lower(contributors) LIKE (?)',
                                     "%#{query}%")
                       )
                       .or(
                         Audio.where('lower(uploader_nickname) LIKE (?)',
                                     "%#{query}%")
                       )
    else
      super
    end
  end

  def results
    if @query.present?
      self.class.search(@query).preload(:searchable).map!(&:searchable).uniq
    else
      Search.none
    end
  end
end
