require "spec_helper"
class Song
  extend Concerns::Findable
  attr_accessor :name, :artist, :genre
  @@all = []
  def initialize(name, artist=nil, genre=nil)
    @name = name
    self.artist=(artist) unless artist == nil
    self.genre=(genre) unless genre == nil
    save
  end
  def self.all
    @@all 
  end
  def self.destroy_all
    self.all.clear
  end
  def save
    @@all << self
  end
  def self.create(song, artist=nil, genre=nil)
    new_song = Song.new(song, artist, genre)
  end
  def artist=(artist)
    @artist = artist
    artist.add_song(self)
  end
  def genre=(genre)
    @genre = genre
    self.genre.songs << self unless genre.songs.include?(self)
  end
  def self.find_by_name(song)
    self.all.detect { |s| s.name == song }
  end
  def self.find_or_create_by_name(song)
    find_by_name(song) || create(song)
  end
  def self.new_from_filename(filename)
    title = filename.split(" - ")
    artist = Artist.find_or_create_by_name(title[0])
    genre = Genre.find_or_create_by_name(title[2][0..-5])
    create(title[1], artist, genre)
  end
  def self.create_from_filename(filename)
    new_from_filename(filename)
  end
end
def self.new_from_filename(filename_str)
  x = filename.split(" - ")
  artist_inst = Artist.find_or_create_by_name(x[0])
  genre_inst = Genre.find_or_create_by_name(x[2][0..-5]) #[^(.mp3)]
  song_inst = Song.new(x[1],artist_inst, genre_inst)
end

describe "Song" do
  let(:song) { Song.new("In the Aeroplane Over the Sea") }

  describe "#initialize" do
    it "accepts a name for the new song" do
      new_song = Song.new("Alison")

      new_song_name = new_song.instance_variable_get(:@name)

      expect(new_song_name).to eq("Alison")
    end
  end

  describe "#name" do
    it "retrieves the name of a song" do
      expect(song.name).to eq("In the Aeroplane Over the Sea")
    end
  end

  describe "#name=" do
    it "can set the name of a song" do
      song.name = "Jump Around"

      song_name = song.instance_variable_get(:@name)

      expect(song_name).to eq("Jump Around")
    end
  end

  describe "@@all" do
    it "is initialized as an empty array" do
      all = Song.class_variable_get(:@@all)

      expect(all).to match_array([])
    end
  end

  describe ".all" do
    it "returns the class variable @@all" do
      expect(Song.all).to match_array([])

      Song.class_variable_set(:@@all, [song])

      expect(Song.all).to match_array([song])
    end
  end

  describe ".destroy_all" do
    it "resets the @@all class variable to an empty array" do
      Song.class_variable_set(:@@all, [song])

      Song.destroy_all

      expect(Song.all).to match_array([])
    end
  end

  describe "#save" do
    it "adds the Song instance to the @@all class variable" do
      song.save

      expect(Song.all).to include(song)
    end
  end

  describe ".create" do
    it "initializes, saves, and returns the song" do
      created_song = Song.create("Kaohsiung Christmas")

      expect(Song.all).to include(created_song)
    end
  end
end
