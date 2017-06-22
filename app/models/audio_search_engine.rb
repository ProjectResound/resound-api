class AudioSearchEngine < ActiveRecord::Base
  extend Textacular

  belongs_to :searchable, polymorphic: true

  self.primary_key = :searchable_id

  def results
    if @query.present?
      self.class.search(@query).preload(:searchable).map!(&:searchable).uniq
    else
      Search.none
    end
  end
end