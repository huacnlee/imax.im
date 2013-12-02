# coding: utf-8
# Hack Topic to work with Merit
class Topic < Homeland::Topic
  def self.find_by_id(id)
    Homeland::Topic.find_by_id(id)
  end
end