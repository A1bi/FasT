# encoding: UTF-8

module DTAUS
  class Collection
    attr_reader :sums
    attr_accessor :transactions
    
    def initialize(sender, reference_key)
      @data = ""
      @sums = {}
      @transactions = []
      @sender = sender
      @reference_key = reference_key
    end
    
    def data
      generate_data
      @data
    end
    
    private
    
    def generate_data
      @data.clear
      @sums.clear
    
      generate_part_a
      generate_part_c
      generate_part_e
    end
  
    def generate_part_a
      add_part_intro "A", 128
    
      add_data @type
    
      # sender info
      fill_with_zeros 8, @sender[:blz]
      fill_with_zeros 8
      fill_with_spaces 27, prepare_text(@sender[:short_name])
    
      add_data Time.now.strftime("%d%m%y")
      fill_with_spaces 4
    
      # additional info
      fill_with_zeros 10, @sender[:account]
      fill_with_zeros 10, @reference_key
      fill_with_spaces 15
    
      # due date
      fill_with_spaces 8
      fill_with_spaces 24
    
      # currency
      add_data 1
    end
  
    def generate_part_c
      @transactions.each do |transaction|
        additions = []
        
        # look if we have to split names because they are too long
        rcp_name = split_and_add_to_additions(transaction.recipient[:name], 1, 1, additions)
        reason = split_and_add_to_additions(transaction.reason, 2, 13, additions)
        sender_name = split_and_add_to_additions(@sender[:name], 3, 1, additions)
      
        additional_sections = additions.count
      
        add_part_intro "C", 187 + additional_sections * 29
      
        # recipient info
        fill_with_zeros 8
        add_to_sum transaction.recipient[:blz], :blz
        fill_with_zeros 8, transaction.recipient[:blz]
        add_to_sum transaction.recipient[:account], :account
        fill_with_zeros 10, transaction.recipient[:account]
        fill_with_zeros 13
      
        # transaction type
        add_data transaction.key
        fill_with_spaces 1
        fill_with_zeros 11
      
        # sender info
        fill_with_zeros 8, @sender[:blz]
        fill_with_zeros 10, @sender[:account]
      
        # total
        total = (transaction.total * 100).to_i
        add_to_sum transaction.total, :total
        fill_with_zeros 11, total
        fill_with_spaces 3
      
        # recipient info
        fill_with_spaces 27, rcp_name
        fill_with_spaces 8
      
        # sender info
        fill_with_spaces 27, sender_name
      
        # reason
        fill_with_spaces 27, reason
        add_data 1
        fill_with_spaces 2
      
        # number of additions
        fill_with_zeros 2, additional_sections
      
        # start with set 2 of 6
        (2..6).each do |i|
          # how many spaces to add after set
          # sets 3-5
          spaces = 12
          max_additions = 4
          if i == 2
            # max 2 additions in set 2
            max_additions = 2
            spaces = 11
          elsif i >= 6
            # max 1 addition in set 6
            max_additions = 1
            spaces = 99
          end
        
          max_additions.times do
            # no more additions ?
            if additions.empty?
              # fill up the remaining additions in this set with spaces
              fill_with_spaces 29
              next
            end
          
            # add the actual addition
            add_addition additions.shift
          end
        
          # spaces which conclude the set
          fill_with_spaces spaces
        
          # no more additions - no more sets
          break if additions.empty?
        end
      end
    end
  
    def generate_part_e
      add_part_intro "E", 128
      fill_with_spaces 5
    
      # number of C parts (transactions)
      fill_with_zeros 7, @transactions.count
    
      # sums
      fill_with_zeros 13
      fill_with_zeros 17, @sums[:account]
      fill_with_zeros 17, @sums[:blz]
      fill_with_zeros 13, (@sums[:total] * 100).to_i
    
      fill_with_spaces 51
    end
    
    def split_and_add_to_additions(text, type, max_add, additions)
      texts = split_text prepare_text(text), 27, max_add
      texts[:add].times do |i|
        additions << { type: type, string: texts[:strings][i.next] }
      end
      texts[:strings].first
    end
  
    def add_addition(addition)
      add_data "0#{addition[:type]}"
      fill_with_spaces 27, addition[:string]
    end
  
    def split_text(text, length, max_add)
      result = { strings: text.scan(/.{1,#{length}}/) }
      result[:add] = [result[:strings].count - 1, max_add].min
      result
    end
  
    def prepare_text(text)
      # replace umlaute
      replacements = { "Ä" => "ae", "ä" => "ae", "Ö" => "oe", "ö" => "oe", "Ü" => "ue", "ü" => "ue", "ß" => "ss" }
      text.gsub! /[#{replacements.keys.join}]/, replacements
      
      text.upcase!
    
      # remove other unsupported characters
      text.gsub /[^\w\.,&-\/ ]/, ""
    end
  
    def add_part_intro(part, length)
      # part length
      fill_with_zeros 4, length
    
      # part identifier
      add_data part
    end
  
    def fill_data_with_character(char, length, data)
      add_data char.to_s * [(length - data.to_s.length), 0].max
    end
  
    def fill_with_zeros(length, data = nil)
      fill_data_with_character "0", length, data
      add_data_with_max_length data, length
    end
  
    def fill_with_spaces(length, data = nil)
      add_data_with_max_length data, length
      fill_data_with_character " ", length, data
    end
  
    def add_data(data)
      @data << data.to_s
    end
  
    def add_data_with_max_length(data, length)
      add_data data.to_s[0..length-1]
    end
  
    def add_to_sum(number, type)
      @sums[type] = (@sums[type] || 0) + number
    end
  end
  
  class ChargeCollection < Collection
    def initialize(sender, reference_key)
      super
      @type = "LK"
    end
  end
  
  module Transactions
    class Base
      attr_reader :total, :recipient, :reason
  
      @@types = { charge: "05000" }
  
      def initialize(total, recipient, reason)
        @total = total
        @recipient = recipient
        @reason = reason
      end
  
      def key
        @@types[@type]
      end
    end
    
    class Charge < Base
      def initialize(total, recipient, reason)
        super
        @type = :charge
      end
    end
  end
end
