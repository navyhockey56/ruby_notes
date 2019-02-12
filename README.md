The purpose of this repository is to provide the ability to take and read notes across ruby terminal sessions.

### Setup
In order to set the repository up locally, you will need to add an environment.rb file. The file defines the sub-module RubyNotesEnvironment which defines the method 'RubyNotesEnvironment.location' which returns the location of your note_taker.rb file, the method 'RubyNotesEnvironment.archive_location' which defines the location of the directory to store your standard notes in, and the method 'RubyNotesEnvironment.personal_location' which defines the location of the directory to store your personal notes in.

### Example of environment.rb:
```ruby
module RubyNotes
 module RubyNotesEnvironment
  def RubyNotesEnvironment.note_taker_location
   '/path/to/note_taker/note_taker.rb'
  end
  def RubyNotesEnvironment.archive_location
   '/path/to/archive_location/'
  end
  def RubyNotesEnvironment.personal_location
   '/path/to/personal_location/'
  end
 end
end
```

### Usage
You can either attach the RubyNotes module to the `self` object, thus giving you direct access to the RubyNotes methods, or you can attach the RubyNotes to any other object, and then access the methods from that object.
To attach the RubyNotes to an object:
```ruby
note_taker = Object.new
RubyNotes.attach_RubyNotes(note_taker)
```
You can also include the RubyNotes module on any other module/class to provide the module/class with access to the RubyNotes methods.

Once the RubyNotes has been made accessible (see above) you can start taking notes, and reading them. To take a note:
```ruby
# note - required
note = 'TODO: Investigate failure blah blah'
# add keyworkds - optional
keyword1 = 'TODO'
# ... more keywords
keywordN = 'Pepsico'
# add a title - optional
title = 'Pepsico TODO'
# Write the note to standard archive
note_taker.write_note note, keyword1, ..., keywordN, title: title
# Write the note to personal archive
note_taker.write_note note, keyword1, ..., keywordN, title: title, personal: true
```

The RubyNotes module will automatically call to_s on any ruby object passed to it as a note. For example, the following will automatically write the supplied list as a note:
```ruby
failed_app_ids = [123123, 242323, 4535252]
note_taker.write_note failed_app_ids, title: "Pepsico failed apps for problem Foo"
```

You can read all the notes you've written today with:
```ruby
note_taker.print_notes
```

If you want to view your notes from the last X days, use:
```ruby
days_ago = 5 # Insert how many days to go back
note_taker.print_notes days_ago: 5
```

If you want to view all the notes you've written, use:
```ruby
note_taker.print_notes days_ago: 'ALL'
```

Remember, the RubyNotes works across terminals, so if you write a note within your mf-applybot console, you can then view that note from any other ruby console you have open, or do open later.
