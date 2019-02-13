require_relative 'environment.rb'
require_relative 'note.rb'
require_relative 'archive.rb'

require 'date'
require 'json'

module RubyNotes

	def RubyNotes.attach_RubyNotes(item)
		item.extend self  
	end

	def reload_note_taker
		load RubyNotes::RubyNotesEnvironment.ruby_notes_location + "/note_taker.rb"
		load RubyNotes::RubyNotesEnvironment.ruby_notes_location + "/archive.rb"
		load RubyNotes::RubyNotesEnvironment.ruby_notes_location + "/note.rb"
	end

	def name_to_archive(name=nil)
		name ||= RubyNotesEnvironment.default_archive
		name += "/" unless name.end_with? '/'
		RubyNotes::NoteArchive.new(name)
	end

	def write_note(note, *keywords, title:'', archive: nil)
		# Exit if no note was given
		return false unless note

		note = Note.new( title: title, note: note.to_s, keywords: Array(keywords))
		archive = name_to_archive(archive)
		archive.add_note(note)
	end

	def print_notes(archive=nil, notes: nil)
		archive = name_to_archive(archive)
		notes ||= archive.get_todays_notes
		notes.each(&:print)
		true
	end

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

	def search_notes(archive: nil)
		raise "Unimplemented"
	end

end