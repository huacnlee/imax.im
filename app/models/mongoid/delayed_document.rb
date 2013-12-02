module Mongoid
  class DelayedDocument
    include Sidekiq::Worker
    sidekiq_options unique: true

    def perform(yml)
      (target, method_name, args) = YAML.load(yml)
      target.send(method_name, *args)
    end
  end
end