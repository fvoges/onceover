require 'onceover/class'
require 'onceover/node'

class Onceover
  class Group
    @@all = []

    # Work out how to do class veriables so that I can keep track of all the groups easily
    attr_accessor :name
    attr_accessor :members

    # You need to pass in an array of strings for members, not objects, it will find the objects
    # by itself, and yes it will reference them, not just create additional ones, woo!

    def initialize(name = nil, members = [])
      @name = name
      @members = []

      if Onceover::Group.valid_members?(members)
        # If it's already a valid list just chuck it in there
        @members = members
      elsif members.is_a?(Hash)
        # if it's a hash then do subtractive stiff
        @members = Onceover::Group.subtractive_to_list(members)
      else
        # Turn it into a full list
        member_objects = []

        # This should also handle lists that include groups
        members.each { |member| member_objects << Onceover::TestConfig.find_list(member) }
        member_objects.flatten!

        # Check that they are all the same type
        unless Onceover::Group.valid_members?(member_objects)
          raise 'Groups must contain either all nodes or all classes. Either there was a mix, or something was spelled wrong'
        end

        # Smash it into the instance variable
        @members = member_objects
      end

      # Finally add it to the list of all grops
      @@all << self
    end

    def self.find(group_name)
      @@all.each do |group|
        if group.name == group_name
          return group
        end
      end
      nil
    end

    def self.all
      @@all
    end

    def self.valid_members?(members)
      # Check that they are all the same type
      # Also catch any errors to assume it's invalid
      begin
        if members.all? { |item| item.is_a?(Onceover::Class) }
          return true
        elsif members.all? { |item| item.is_a?(Onceover::Node) }
          return true
        else
          return false
        end
      rescue
        return false
      end
    end

    def self.subtractive_to_list(subtractive_hash)
      # Take a hash that looks like this:
      # { 'include' => 'somegroup'
      #   'exclude' => 'other'}
      # and return a list of classes/nodes
      include_list = Onceover::TestConfig.find_list(subtractive_hash['include'])
      exclude_list = Onceover::TestConfig.find_list(subtractive_hash['exclude'])
      include_list - exclude_list
    end
  end
end
