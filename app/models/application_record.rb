class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  is_impressionable
end
