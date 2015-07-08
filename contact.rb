require 'pg'
require 'pry'

class Connection

  def self.new_connection
    conn = PG.connect(
      host: 'localhost',
      dbname: 'contacts',
      user: 'sonny',
      password: 'sonny'
    )
  end

end

class Contacts

  attr_reader :id
  attr_accessor :firstname, :lastname, :email
 
  def initialize(firstname, lastname, email, id = nil)
    @firstname = firstname
    @lastname = lastname
    @email = email
    @id = id
  end

  def self.all
    all_contacts = []
    conn = Connection.new_connection
    conn.exec("SELECT * FROM contacts;").each do |row|
      all_contacts << Contacts.new(row["firstname"], row["lastname"], row["email"], row["id"])
    end
    all_contacts.map do |object|
      object.to_s
    end
  end

  def to_s
    "Contact #{id} is #{firstname} #{lastname} #{email}"
  end

  def save
    conn = Connection.new_connection
    if id
      puts "Updating" 
      conn.exec_params("UPDATE contacts SET firstname = $1, lastname = $2, email = $3 WHERE id = $4",
        [firstname, lastname, email, id])
    else
      puts "Creating"
      result = conn.exec_params("INSERT INTO contacts (firstname, lastname, email)
        VALUES($1, $2, $3) RETURNING id", [firstname, lastname, email])
      @id = result[0]["id"]
    end
  end

  def self.find (find_id)
    conn = Connection.new_connection
    found_contact = nil
    conn.exec_params("SELECT * FROM contacts WHERE id = $1;", [find_id]).map do |row|
      found_contact = Contacts.new(row["firstname"], row["lastname"], row["email"], row["id"])
    end
    found_contact.to_s
  end

  def self.find_by_email(find_email)
    conn = Connection.new_connection
    found_contact = nil
    conn.exec_params("SELECT * FROM contacts WHERE email = $1;", [find_email]).map do |row|
      found_contact = Contacts.new(row["firstname"], row["lastname"], row["email"], row["id"])
    end
    found_contact.to_s
  end

  def self.find_all_by_lastname(name)
    conn = Connection.new_connection
    found_contacts = []
    conn.exec_params("SELECT * FROM contacts WHERE lastname = $1;", [name]).map do |row|
      found_contacts << Contacts.new(row["firstname"], row["lastname"], row["email"], row["id"])
    end
    found_contacts.map do |object|
      object.to_s
    end
  end

  def self.find_all_by_firstname(name)
    conn = Connection.new_connection
    found_contacts = []
    conn.exec_params("SELECT * FROM contacts WHERE firstname = $1;", [name]).map do |row|
      found_contacts << Contacts.new(row["firstname"], row["lastname"], row["email"], row["id"])
    end
    found_contacts.map do |object|
      object.to_s
    end
  end

  def destroy
    conn = Connection.new_connection
    sql = "DELETE FROM contacts WHERE id = $1;"
    conn.exec_params(sql, [@id])
  end

end



case ARGV[0]

when "help"
  puts  "Here is a list of available commands:"
  puts  "save  - Create or update a contact"
  puts  "all - List all contacts"
  puts  "find - Find a contact by id, firstname, lastname or email"
when "save"
  
  puts "Enter firstname"
  user_input_firstname = STDIN.gets.chomp
  puts "Enter lastname"
  user_input_lastname = STDIN.gets.chomp
  puts "Enter email"
  user_input_email = STDIN.gets.chomp
  new_contact = Contacts.new(user_input_firstname, user_input_lastname, user_input_email)
  new_contact.save

when "all"
  puts Contacts.all
when "find"
  case ARGV[1]
    when "id" 
      puts "Found by ID: "
      puts Contacts.find(ARGV[2])
    when "firstname" 
      puts "Found by Firstname: "
      puts Contacts.find_all_by_firstname(ARGV[2])
    when "lastname" 
      puts "Found by Lastname: "
      puts Contacts.find_all_by_lastname(ARGV[2])
    when "email" 
      puts "Found by Email: "
      puts Contacts.find_by_email(ARGV[2])
    else
    puts "You're just making it up!"
    end
else
  puts "You're just making it up!"
end

# CREATE TABLE contacts (
#   id        serial NOT NULL PRIMARY KEY,
#   firstname varchar(40) NOT NULL,
#   lastname  varchar(40) NOT NULL,
#   email     varchar(40) NOT NULL
# );