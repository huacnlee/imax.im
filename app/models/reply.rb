# coding: utf-8
# Hack reply to work with Merit
class Reply < Homeland::Reply
  def self.find_by_id(id)
    Homeland::Reply.find_by_id(id)
  end
end