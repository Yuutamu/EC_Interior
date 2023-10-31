class ApplicationRecord < ActiveRecord::Base
  # @sort latest
  primary_abstract_class
  scope :latest, -> { order(created_at: :desc) }
end
