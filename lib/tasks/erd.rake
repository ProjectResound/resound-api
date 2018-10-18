# frozen_string_literal: true

desc 'Generate Entity Relationship Diagram'
task :generate_erd do
  system 'erd --inheritance --direct --attributes=foreign_keys,content'
end
