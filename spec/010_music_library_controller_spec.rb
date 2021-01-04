require "spec_helper"
class MusicLibraryController
  def initialize(path = './db/mp3s')
    importer = MusicImporter.new(path)
    importer.import
  end
  def call
    input = ''
    while input != 'exit'
      puts "Welcome to your music library!"
      puts "To list all of your songs, enter 'list songs'."
      puts "To list all of the artists in your library, enter 'list artists'."
      puts "To list all of the genres in your library, enter 'list genres'."
      puts "To list all of the songs by a particular artist, enter 'list artist'."
      puts "To list all of the songs of a particular genre, enter 'list genre'."
      puts "To play a song, enter 'play song'."
      puts "To quit, type 'exit'."
      puts "What would you like to do?"
      input = gets.chomp
      case input
      when 'list songs'
        self.list_songs
      when 'list artists'
        self.list_artists
      when 'list genres'
        self.list_genres
      when 'list artists'
        self.list_artists
      when 'list artist'
        self.list_songs_by_artist
      when 'list genre'
        self.list_songs_by_genre
      when 'play song'
        self.play_song
      else
        "Type in a valid request please"
      end
    end
  end
  def list_songs
    Song.all.sort {|a,b| a.name <=> b.name}.each.with_index(1) do |song, i|
      puts "#{i}. #{song.artist.name} - #{song.name} - #{song.genre.name}"
    end
  end
  def list_artists
    artists = Artist.all.sort {|a,b| a.name <=> b.name}
    artists.each.with_index(1) {|artist, i| puts "#{i}. #{artist.name}"}
  end
  def list_genres
    genres = Genre.all.sort {|a,b| a.name <=> b.name}
    genres.each.with_index(1) {|genre, i| puts "#{i}. #{genre.name}"}
  end
  def list_songs_by_artist
    puts "Please enter the name of an artist:"
    input = gets.strip
    if artist = Artist.find_by_name(input)
      artist.songs.sort { |a,b| a.name <=> b.name }.each.with_index(1) do |song, i|
        puts "#{i}. #{song.name} - #{song.genre.name}"
      end
    end
  end
  def list_songs_by_genre
    puts "Please enter the name of a genre:"
    input = gets.strip
    if genre = Genre.find_by_name(input)
      genre.songs.sort { |a,b| a.name <=> b.name }.each.with_index(1) do |song, i|
        puts "#{i}. #{song.artist.name} - #{song.name}"
      end
    end
  end
  def play_song
    puts "Which song number would you like to play?"
    input = gets.chomp.to_i
    songs = Song.all
    if (1..songs.length).include?(input)
      song = Song.all.sort{ |a, b| a.name <=> b.name }[input - 1]
    end
    puts "Playing #{song.name} by #{song.artist.name}" if song
  end
end

describe "MusicLibraryController" do
  describe "#initialize" do
    it "accepts one argument, the path to the MP3 files to be imported" do
      expect{ MusicLibraryController.new("./spec/fixtures/mp3s") }.to_not raise_error
    end

    it "creates a new MusicImporter object, passing in the 'path' value" do
      expect(MusicImporter).to receive(:new).with("./spec/fixtures/mp3s").and_return(double(MusicImporter, import: true))

      MusicLibraryController.new("./spec/fixtures/mp3s")
    end

    it "the 'path' argument defaults to './db/mp3s'" do
      expect(MusicImporter).to receive(:new).with("./db/mp3s").and_return(double(MusicImporter, import: true))

      MusicLibraryController.new
    end

    it "invokes the #import method on the created MusicImporter object" do
      music_importer = MusicImporter.new("./spec/fixtures/mp3s")

      expect(MusicImporter).to receive(:new).and_return(music_importer)
      expect(music_importer).to receive(:import)

      MusicLibraryController.new
    end
  end

  describe "#call" do
    let(:music_library_controller) { MusicLibraryController.new("./spec/fixtures/mp3s") }

    it "welcomes the user" do
      allow(music_library_controller).to receive(:gets).and_return("exit")

      expect($stdout).to receive(:puts).with("Welcome to your music library!")
      expect($stdout).to receive(:puts).with("To list all of your songs, enter 'list songs'.")
      expect($stdout).to receive(:puts).with("To list all of the artists in your library, enter 'list artists'.")
      expect($stdout).to receive(:puts).with("To list all of the genres in your library, enter 'list genres'.")
      expect($stdout).to receive(:puts).with("To list all of the songs by a particular artist, enter 'list artist'.")
      expect($stdout).to receive(:puts).with("To list all of the songs of a particular genre, enter 'list genre'.")
      expect($stdout).to receive(:puts).with("To play a song, enter 'play song'.")
      expect($stdout).to receive(:puts).with("To quit, type 'exit'.")
      expect($stdout).to receive(:puts).with("What would you like to do?")

      music_library_controller.call
    end

    it "asks the user for input" do
      allow(music_library_controller).to receive(:gets).and_return("exit")

      expect(music_library_controller).to receive(:gets)

      capture_puts { music_library_controller.call }
    end

    it "loops and asks for user input until they type in exit" do
      allow(music_library_controller).to receive(:gets).and_return("a", "b", "c", "exit")

      expect(music_library_controller).to receive(:gets).exactly(4).times

      capture_puts { music_library_controller.call }
    end
  end
end
