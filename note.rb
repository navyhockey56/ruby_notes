module RubyNotes

	class Note

		attr_reader :title, :note, :keywords, :timestamp

		def initialize(title:, note:, keywords:, timestamp:nil)
			@timestamp = timestamp
			@timestamp ||= Time.now
			
      @title = title 
			@note = note 
			@keywords = keywords
		end

		def Note.restore(hash_of_note)
			hash_of_note.keys.each do |key| 
				hash_of_note[key.to_sym] = hash_of_note.delete(key) unless (key.class == Symbol)
			end
			Note.new(hash_of_note)
		end

		def to_hash
			{
				title: @title,
				keywords: @keywords,
				timestamp: @timestamp.to_s,
				note: @note
			}
		end

    def to_pretty_json
      JSON.pretty_generate(self.to_hash)
    end

		def inspect
			to_hash
		end

		def to_s
			delinator = '------------------------------------------------'
			"#{delinator}\n#{timestamp}\n\nTitle: #{@title}\n\n#{@note}\n\nKeywords: #{@keywords}"
		end

    def print
      puts self
    end

	end

end