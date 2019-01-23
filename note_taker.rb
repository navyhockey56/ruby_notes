# You need an environment.rb file that sits next to your note_taker.
# The environment.rb file must: 
# - Define module NoteTaker::NoteTakerEnvironment
# - Define class level methods: 'note_taker_location', 'archive_location', 'personal_location'
# 	where 'note_taker_location' defines the location of this file;
#   'arvhive_location' defines the folder to keep your notes in;
# 	and 'personal_location' defines the folder to keep your personal notes in (notes 
#   you don't wish to show up on a normal call to print_notes)
require_relative 'environment.rb'
require 'Date'
require 'Json'

module NoteTaker

	def NoteTaker.attach_notetaker(item)
		item.extend self  
	end

	def reload_note_taker
		load NoteTaker::NoteTakerEnvironment.note_taker_location
	end

	def write_note(note, *keywords, title:'', personal: false)
		return false unless note
		note = Note.new( title: title, note: note.to_s, keywords: Array(keywords), personal: personal)
		note.write
	end

	def read_notes(date_string:nil, days_ago:nil, personal: false)

		directory = personal ? 
				NoteTaker::NoteTakerEnvironment.personal_location : 
				NoteTaker::NoteTakerEnvironment.archive_location

		if date_string == 'ALL'
			notes = [] 
			file_names = Dir[directory + '*.json']
			file_names.each { |file_name|
				notes += eval(File.read(file_name))
			}
			notes.reverse.map { |note| Note.restore(note) } 
		elsif days_ago
			# Retrieves the notes from today to the past :days_ago 
			notes = []
			date = Date.today 
			file_names = Dir[directory + '*.json']
			(0..days_ago).each {
				file_name = "#{directory}#{date.to_s}.json"
				date = date.prev_day
				notes += eval(File.read(file_name)).reverse if file_names.include? file_name		
			} 
			notes.reverse.map { |note| Note.restore(note) } 
		else   
			date_string ||= Date.today.to_s
			file_name ||= directory + date_string + ".json"
			raise "Note not found" unless File.exist? file_name
			eval(File.read(file_name)).map { |note| Note.restore(note) } 
		end	
	end

	def print_notes(date_string:nil, days_ago:nil, personal: false)
		notes_array = read_notes(date_string: date_string, days_ago: days_ago, personal: personal)
		notes_array.each { |note| puts note }
		true
	end

	def search_notes(keywords:[], pattern:nil, start_date:nil, number_of_days: nil, personal: false)
		
		# Retrieve the notes
		notes = read_notes(date_string:"ALL", personal: personal) unless start_date
		notes ||= get_notes_for_date_range(start_date, number_of_days, personal)

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

	def get_notes_for_date_range(start_date, number_of_days=5, personal=false)
		
		directory = personal ? 
				NoteTaker::NoteTakerEnvironment.personal_location : 
				NoteTaker::NoteTakerEnvironment.archive_location

		notes = [] 
		date = Date.parse(start_date)
		file_names = Dir[directory + '*.json']
		(1...number_of_days).each do
			file_name = "#{directory}#{date.to_s}.json"
			date = date.next_day
			notes += eval(File.read(file_name)) if file_names.include? file_name
		end
		notes.map {|note| Note.restore(note) } 
	end

	def print_notes_for_date_range(start_date, number_of_days=5, personal=false)
		notes_array = get_notes_for_date_range(start_date, number_of_days, personal)
		notes_array.each { |note| puts note }
		true 
	end

	class Note

		attr_reader :title, :note, :keywords, :timestamp

		def initialize(title:, note:, keywords:, timestamp:nil, personal: false)
			@timestamp = timestamp
			@timestamp ||= Time.now
			@title = title 
			@note = note 
			@keywords = keywords
			@personal = personal
		end

		def Note.restore(hash_of_note)
			Note.new(hash_of_note)
		end

		def to_hash
			{
				title: @title,
				keywords: @keywords,
				timestamp: @timestamp.to_s,
				note: @note,
				personal: @personal 
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
			file_name = get_directory + date_string + ".json"

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

		def get_directory
			@personal ? 
				NoteTaker::NoteTakerEnvironment.personal_location : 
				NoteTaker::NoteTakerEnvironment.archive_location 
		end

	end

end