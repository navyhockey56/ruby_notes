# You need an environment.rb file that sits next to your note_taker.
# The environment.rb file must: 
# - Define module NoteTaker::NoteTakerEnvironment
# - Define class level methods: 'note_taker_location', 'archive_location'
# 	where 'note_taker_location' defines the location of this file
#   and 'arvhive_location' defines the folder to keep your notes in
require_relative 'environment.rb'
require 'Date'

module NoteTaker

	def NoteTaker.attach_notetaker(item)
		item.extend self  
	end

	def reload_note_taker
		load NoteTaker::NoteTakerEnvironment.note_taker_location
	end

	def write_note(note, *keywords, title:'')
		return false unless note
		note = Note.new( title: title, note: note.to_s, keywords: Array(keywords))
		note.write
	end

	def read_notes(date_string:nil, days_ago:nil)
		if date_string == 'ALL'
			notes = [] 
			file_names = Dir[NoteTaker::NoteTakerEnvironment.archive_location + '*.json']
			file_names.each { |file_name|
				notes += eval(File.read(file_name))
			}
			notes.reverse.map { |note| Note.restore(note) } 
		elsif days_ago
			# Retrieves the notes from today to the past :days_ago 
			notes = []
			date = Date.today 
			file_names = Dir[NoteTaker::NoteTakerEnvironment.archive_location + '*.json']
			(0..days_ago).each {
				file_name = "#{NoteTaker::NoteTakerEnvironment.archive_location}#{date.to_s}.json"
				date = date.prev_day
				notes += eval(File.read(file_name)).reverse if file_names.include? file_name		
			} 
			notes.reverse.map { |note| Note.restore(note) } 
		else   
			date_string ||= Date.today.to_s
			file_name ||= NoteTaker::NoteTakerEnvironment.archive_location + date_string + ".json"
			raise "Note not found" unless File.exist? file_name
			eval(File.read(file_name)).map { |note| Note.restore(note) } 
		end	
	end

	def print_notes(date_string:nil, days_ago:nil)
		notes_array = read_notes(date_string: date_string, days_ago: days_ago)
		notes_array.each { |note| puts note }
		true
	end

	def search_notes(keywords:[], pattern:nil, start_date:nil, number_of_days: nil)
		
		# Retrieve the notes
		notes = read_notes(date_string:"ALL") unless start_date
		notes ||= notes_for_data_range(start_date, number_of_days)

		unless keywords.empty?
			# Remove any notes missing the required keywords
			notes.select! { |note| (keywords & note.keywords) == keywords } 
		end

		if pattern
			raise ":pattern must be a Regexp" unless pattern.class == Regexp
			notes.select! { |note| note.note =~ pattern} 
		end

		notes
	end

	def get_notes_for_date_range(start_date, number_of_days=5)
		notes = [] 
		date = Date.parse(start_date)
		file_names = Dir[Note::ARCHIVE + '*.json']
		(1...number_of_days).each do
			file_name = "#{Note::ARCHIVE}#{date.to_s}.json"
			date = date.next_day
			notes += eval(File.read(file_name)) if file_names.include? file_name
		end
		notes.map {|note| Note.restore(note) } 
	end

	def print_notes_for_date_range(start_date, number_of_days=5)
		notes_array = get_notes_for_date_range(start_date, number_of_days)
		notes_array.each { |note| puts note }
		true 
	end

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

		def inspect
			to_hash
		end

		def to_s
			delinator = '------------------------------------------------'
			"#{delinator}\n#{timestamp}\n\nTitle: #{@title}\n\n#{@note}\n\nKeywords: #{@keywords}"
		end

		def write  
			date_string = @timestamp.to_s.split[0] 
			file_name = NoteTaker::NoteTakerEnvironment.archive_location + date_string + ".json"

			notes_json = nil
			if File.exist? file_name
				notes_json = JSON.load(File.read(file_name))
			else
				notes_json = []
			end

			notes_json << self.to_hash
			pretty_note = JSON.pretty_generate(notes_json)
			File.open(file_name, 'w') { |f| f.write(pretty_note) }
			
			true
		end
	end

end