require_relative 'environment.rb'
require_relative 'note.rb'
require_relative 'archive.rb'

require 'date'
require 'json'

module RubyNotes

	# Mixes in the RubyNots module to the given object
	# @param [Object] obj - any object
	# @return [RubyNotes] The passed in object 
	def RubyNotes.attach_RubyNotes(obj)
		obj.extend self  
	end

	# Reloads your changes to the repo
	def reload_note_taker
		load RubyNotes::RubyNotesEnvironment.ruby_notes_location + "/note_taker.rb"
		load RubyNotes::RubyNotesEnvironment.ruby_notes_location + "/archive.rb"
		load RubyNotes::RubyNotesEnvironment.ruby_notes_location + "/note.rb"
	end

	# Retrieves an existing archive
	# @param [String] name - The name of the archive, or nil to use the default archive
	# @return [NoteArchive] The archive
	def name_to_archive(name=nil)
		name ||= RubyNotesEnvironment.default_archive
		name += "/" unless name.end_with? '/'
		RubyNotes::NoteArchive.new(name)
	end

	# Writes a new note to the specified archive
	def write_note(note, *keywords, title:'', archive: nil)
		# Exit if no note was given
		return false unless note

		note = Note.new( title: title, note: note.to_s, keywords: Array(keywords))
		archive = name_to_archive(archive)
		archive.add_note(note)
	end

	# Prints today's notes for the specified archive
	def print_notes(archive=nil)
		archive = name_to_archive(archive)
		notes = archive.get_todays_notes
		notes.each(&:print)
		true
	end

	# Prints all note sof rhte specified archive
	def print_all_notes(archive=nil)
		archive = name_to_archive(archive)
		archive.get_all_notes.each(&:print)
		true
	end

	def print_this_weeks_notes(archive=nil)
		archive = name_to_archive(archive)
		archive.get_this_weeks_notes.each(&:print)
		true
	end

	def print_notes_on(date_string, archive=nil)
		archive = name_to_archive(archive)
		archive.get_notes_on(date_string).each(&:print)
		true
	end

	def print_recent_notes(days_ago, archive=nil)
		archive = name_to_archive(archive)
		archive.get_recent_notes(days_ago).each(&:print)
		true
	end

	def print_notes_in_range(start_range=nil, end_range=nil, archive=nil)
		archive = name_to_archive(archive)
		archive.get_notes_in_range(start_range, end_range).each(&:print)
		true
	end

	def search_notes(archive: nil)
		raise "Unimplemented"
	end

	def create_new_archive(name)
    location = RubyNotes::RubyNotesEnvironment.archive_location + name
      
    raise ("A directory already exists at location #{location}. " \
           "You must remove this location manually if you want to replace it.") if File.directory?(location)

    raise "A non-directory file exists at location #{location}. Notes cannot be written here." if File.exists?(location)
      
    puts "Creating a new archive at: #{location}"
    `mkdir #{location}`
      
    RubyNotes::NoteArchive.new(location)
  end

  def get_all_archives
    Dir[RubyNotes::RubyNotesEnvironment.archive_location + "*"].map do |f|
      if File.directory?(f)
        RubyNotes::NoteArchive.new(f)
      else
        nil
      end
    end.compact
  end

end