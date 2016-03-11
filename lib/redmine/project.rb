require 'time'
require 'redmine/value'

module Redmine
  # A project is a container of issues.
  class Project < Value
    attribute :id, type: Integer
    attribute :name
    attribute :identifier
    attribute :description
    attribute :status
    attribute :parent
    attribute :created_on, type: DateTime
    attribute :updated_on, type: DateTime
  end
end
