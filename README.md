The purpose of this repository is to provide the ability to take and read notes across ruby terminal sessions.

### Setup
In order to set the repository up locally, you will need to add an environment.rb file. The file defines the sub-module RubyNotesEnvironment. The RubyNotesEvironment defines where you're copy of ruby notes is stored locally, the directory that you want to keep your notes in, and which archive you want to use by default. 

### Example of environment.rb:
```ruby
module RubyNotes
 module RubyNotesEnvironment
  def RubyNotesEnvironment.ruby_notes_location
   '/path/to/your/copy/of/ruby_notes/'
  end
  def RubyNotesEnvironment.archive_location
   '/path/to/directory/where/you/want/to/store/notes/in/'
  end
  def RubyNotesEnvironment.default_archive
    'the-name-of-an-archive-you-want-to-use-by-default'
  end
 end
end
```

### Usage
You can either attach the RubyNotes module to the `self` object, thus giving you direct access to the RubyNotes methods, or you can attach the RubyNotes to any other object, and then access the methods from that object.
To attach the RubyNotes to an object:
```ruby
note_taker = RubyNotes.attach_RubyNotes(Object.new)
```
You can also include the RubyNotes module on any other module/class to provide the module/class with access to the RubyNotes methods.

Once the RubyNotes has been made accessible (see above) you can start taking notes, and reading them. To take a note:
```ruby
# note - required
note = 'TODO: Lots and lots of things'
# add keyworkds - optional
keyword1 = 'TODO'
# ... more keywords
keywordN = 'Important'
# add a title - optional
title = 'Important TODO!!!'
# specify the archive to store the note in - optional, if not specified, the RubyNotesEvironment.default_archive will be used.
archive = 'Important'
# Write the note
note_taker.write_note note, keyword1, ..., keywordN, title: title, archive: archive
```

The RubyNotes module will automatically call to_s on any ruby object passed to it as a note. For example, the following will automatically write the supplied list as a note:
```ruby
some_numbers = [123123, 242323, 4535252]
note_taker.write_note some_numbers, title: "Random Numbers"
```

You can read all the notes you've written in an archive today with:
```ruby
# default archive
note_taker.print_notes
# or you can specify a different archive
note_taker.print_notes 'archive-to-print'
```

If you want to view your notes from the last X days, use:
```ruby
number_of_days_to_go_back = 5
# defualt archive
note_taker.print_recent_notes number_of_days_to_go_back
# or you can specify a different archive
note_taker.print_recent_notes number_of_days_to_go_back, 'archive-to-print'
```

If you want to view all notes from this week, use:
```ruby
# default archive
note_taker.print_this_weeks_notes
# or you can specify a different archive
note_taker.print_this_weeks_notes 'archive-to-print'
```

If you want to view all the notes you've written for an archive, use:
```ruby
# default archive
note_taker.print_all_notes
# or you can specify a different archive
note_taker.print_all_notes 'archive-to-print'
```

If you want to print notes between the last X days up to the last Y days ("Print notes from the last 10 to 15 days ago"), use:
```ruby
start_printing_notes_from_this_many_days_ago = 10
keep_printing_notes_up_to_and_including_this_many_days_ago = 15
# defualt archive
note_taker.print_notes_in_range start_printing_notes_from_this_many_days_ago, keep_printing_notes_up_to_and_including_this_many_days_ago
# or you can specify a different archive
note_taker.print_notes_in_range start_printing_notes_from_this_many_days_ago, keep_printing_notes_up_to_and_including_this_many_days_ago, 'archive-to-print'
```

You can search for and print specific notes using the search method. With search you can specify any combination of: 
- title: limits the search to notes with the given title.
- keywords: limits the search to notes that include at least one suplied keywords.
- includes: limits the search to notes that contain the supplied subtring.
- pattern: limits the search to notes that match the given Regex pattern.
If none of the parameters are passed to search, then all notes from the archive will be returned. If two or more parameters are used, then the notes will be limited to only those that meet all parameters. 
```ruby
# specify which title the notes must have - optional
title = "Important"
# specify the keywords the notes must have one of - optional
keywords = ['you have to have this keyword', 'or this would work as well', 'this one too, im not picky']
# specify a substring that must be in the notes - options
substring = 'coding is the best'
# specify a regex pattern the note must conform to
pattern = /[0-9]+/
# specify which arhive to search - option, uses default archive if not specified
archive = 'system'
# perform the search
note_taker.search title: title, keywords: keywords, includes: substring, pattern: pattern, archive: archive
```

The RubyNotes works across terminals, so if you write a note within one ruby session, you can then immediately view that note from any other ruby session you have open (note: this can be used as a hacky way of passing objects from session to session)
