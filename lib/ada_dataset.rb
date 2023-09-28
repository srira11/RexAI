require 'csv'
require 'json'

class AdaDataset
  @records = []

  class << self
    attr_reader :records
    def parse
      CSV.foreach(Rails.root.to_s << '/lib/assets/ada-export-rently-2023-09-06.csv', headers: true) do |row|
        next if row[4] == nil

        questions = row[4].split(/\n/).map { _1[2..] }
        next if row[3].match? /capture(:|\ ')/

        texts = row[3].split("\n").inject([]) do |acc, line|
          matches = line.scan(/(?:(?<=→ (text|link): )|(?<=→ (picture): )|(?<=→ (video): ))(.*)$/).map!(&:compact)
          if !matches.empty?
            acc += matches
          else
            matches = line.scan(/^(?!.*->.*)[^:•→\n\r]+$/).map! { ['text', _1] }
            acc += matches unless matches.empty?
          end
          acc
        end

        answer = process_answers(texts).join("\n")
        next if answer == ''

        replace_emojis(answer)

        @records << { questions:, answer: }
      end
    end

    private

    def replace_emojis(str)
      # Since some of the emojis are used in an instruction, they have to be replaced with text.

      convert_hash = {
        "✏️" => "Edit icon",
        "➡️" => ">",
        "🔔" => "Bell icon",
        "1️⃣" => "1.",
        "2️⃣" => "2.",
        "3️⃣" => "3.",
        "4️⃣" => "4.",
        "5️⃣" => "5.",
        "6️⃣" => "6.",
        "🔴" => "red",
        "🟠" => "orange",
        "🟢" => "green",
        "🔵" => "blue",
        "✅" => "tick",
        "#⃣" => "# button"
      }

      # A regex to match all the emojis in the dataset
      str.gsub!(/[0-9#]?[^\w\d\s!"#$%&'()+,.\/:;=>?@\[\]_-]+/, convert_hash)
    end

    def process_answers(answers)
      hints_for_handoff = [
        %w(agents help),
        %w(Agent help),
        %w(human assist),
        %w(button below),
        %w(option below),
        ['fill out an application'],
        ['select Contact Support'],
        ['Let me explain:'] # special redirection scenario, should remove afterwards
      ]

      answers.map! do |answer|
        if answer[0] == 'text'
          if hints_for_handoff.any? { |combination| combination.all? { |word| answer[1].include?(word) } }
            nil
          elsif answer[1].strip.end_with?('below:') || answer[1].strip.end_with?('?')
            nil
          else
            answer[1]
          end
        elsif answer[0] == 'picture'
          'Refer this image: ' << answer[1]
        elsif answer[0] == 'video'
          'Here is the video link: ' << answer[1]
        else
          answer[1]
        end
      end

      answers[0] == nil ? [] : answers.compact
    end
  end
end
