# frozen_string_literal: true

namespace :members do
  task add_gender: :environment do
    Members::Member.find_each.with_index do |member, i|
      puts "#{i}."
      puts "Name: #{member.name.full}"
      puts 'f[a]/m[s]?'
      gender = nil
      until gender.present?
        gender = $stdin.gets.strip
        gender = { a: 'female', s: 'male' }[gender.to_sym]
      end
      member.update(gender: gender)
    end
  end
end
