require 'pry'

module Alice

  module Behavior

    module Steals

      def recently_stole?
        self.last_theft ||= DateTime.now - 1.day
        self.last_theft >= DateTime.now - 13.minutes
      end

      def steal(what)
        return "thinks that #{proper_name} shouldn't press #{self.pronoun_possessive} luck on the thievery front." if recently_stole?

        item = what if what.respond_to?(:name)
        item ||= Item.from(name: what.downcase).last || Beverage.from(name: what.downcase).last
        return "eyes #{proper_name} curiously." unless item
        return "#{Alice::Util::Randomizer.laugh} as #{proper_name} tries to steal #{self.pronoun_possessive} own #{item.name}!" if item.owner == self
        return "apologizes, but #{item.owner_name} locked that up tight before going to sleep!" unless item.owner.awake?

        if Alice::Util::Randomizer.one_chance_in(5)
          update_thefts
          if item.point_value > 1
            message = "stares in surprise as #{proper_name} steals the #{item.name}, worth #{item.point_value} Internet Points™, from #{item.owner_name}!"
          else
            message = "watches in wonder as #{proper_name} snatches the #{item.name} from #{item.owner_name}'s pocket!"
          end
          item.remove
          item.reset_theft_attempts
          self.items << item
          self.score_points if self.respond_to?(:score_points)
        else
          update_thefts
          message = "sees #{proper_name} try and fail to take the #{item.name} from #{item.owner_name}."
          item.increment_theft_attempts
          self.penalize if self.respond_to?(:penalize)
        end
        message
      end

      def update_thefts
        self.update_attributes(last_theft: DateTime.now)
      end

    end

  end

end