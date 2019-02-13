module RubyNotes

  class NoteArchive

    attr_reader :name, :location

    def initialize(location)
      unless location.start_with? RubyNotes::RubyNotesEnvironment.archive_location
       location = RubyNotes::RubyNotesEnvironment.archive_location + location 
      end

      raise "There is not a directory at #{location}." if !File.directory?(location)
      @location = location
      @name = location.gsub(RubyNotes::RubyNotesEnvironment.archive_location, '')
    end

    def create_file_name(date_string)
      @location + date_string + ".rnote"
    end

    def add_note(note)
      date_string = note.timestamp.to_s.split[0] 
      file_name = create_file_name(date_string)

      notes_json = nil
      if File.exist? file_name
        notes_json = JSON.load(File.read(file_name))
      else
        notes_json = []
      end

      notes_json << note.to_hash
      pretty_note = JSON.pretty_generate(notes_json)
      File.open(file_name, 'w') { |f| f.write(pretty_note) }
      true
    end

    def get_all_notes
      notes = [] 
      file_names = Dir[@location + '*.rnote'].sort
      file_names.each { |file_name|
        notes += JSON.parse(File.read(file_name))
      }
      notes.map { |note| Note.restore(note) } 
    end

    def get_todays_notes
      get_notes_on(Date.today.to_s)
    end

    def get_this_weeks_notes
      raise "Unimplemented"
    end

    def get_notes_on(date_string)
      file_name = create_file_name(date_string)
      raise "Could not find any notes for: #{date_string}." unless File.exist? file_name
      JSON.parse(File.read(file_name)).map { |note| Note.restore(note) } 
    end

    def get_recent_notes(days_ago)
      notes = []
      date = Date.today 
      file_names = Dir[@location + '*.rnote']
      (0..days_ago).each {
        file_name = "#{@location}#{date.to_s}.rnote"
        date = date.prev_day
        notes += JSON.parse(File.read(file_name)).reverse if file_names.include? file_name    
      } 
      notes.reverse.map { |note| Note.restore(note) } 
    end

    def get_notes_in_range(start: nil, end: nil)
      raise "Unimplemented"
    end

    def search(title: nil, keywords: nil, includes: nil, pattern: nil)
      raise "Unimplemented"

      # Retrieve the notes
      #notes = read_notes(date_string:"ALL", personal: personal) unless start_date
      #notes ||= get_notes_for_date_range(start_date, number_of_days, personal)

      #unless keywords.empty?
        # Remove any notes missing the required keywords
      #  notes.select! { |note| (keywords & note.keywords) == keywords } 
      #end

      #if pattern
      #  raise ":pattern must be a Regexp" unless pattern.class == Regexp
      #  notes.select! { |note| note.note =~ pattern} 
      #end

      #notes
    end

  end

end