require "json"

class Inventory
    def initialize(title, author, isbn)
        @books_file = "books.json"
        @books = []
        add_book(title, author, isbn)
    end

    def load_books
        if File.exist?(@books_file)
            File.readlines(@books_file).each do |line|
                @books.push(JSON.parse(line))
            end
        end
    end

    def add_book(title, author, isbn)
        @books.push({'title'=> title, 'author'=> author, 'isbn'=> isbn})
        save_books
    end

    def save_books
        File.open(@books_file, "w") do |file|
            @books.each do |book|
                file.puts(book.to_json)
            end
        end
    end

    def list_books
        @books.each do |book|
            puts "#{book['title']} by #{book['author']} has ISBN: #{book['isbn']}"
        end
    end

    def remove_book(isbn)
        @books.delete_if { |book| book['isbn'] == isbn }
        save_books
    end

    def sort_books_by_isbn
        @books.sort_by! { |book| book['isbn'].to_i }
        save_books
        puts "Books sorted by ISBN"
    end

    def search_books_by_title(title)
        found_books = @books.select { |book| book['title'].strip.downcase.include?(title.strip.downcase)}
        display_search_results(found_books)
    end

    def search_books_by_author(author)
        found_books = @books.select { |book| book['author'].strip.downcase.include?(author.strip.downcase)}
        display_search_results(found_books)
    end

    def search_books_by_isbn(isbn)
        found_books = @books.select { |book| book['isbn'].strip.downcase == isbn.strip.downcase }
        display_search_results(found_books)
    end

    private

    def display_search_results(books)
        puts "Found #{books.length} books"
        books.each do |book|
            puts "Title: #{book['title']}, Author: #{book['author']}, ISBN: #{book['isbn']}"
        end
    end
end

inventory = Inventory.new("The Great Gatsby", "Fakhr", "1")

#User CLI
loop do
    puts "1. List Books"
    puts "2. Add Book"
    puts "3. Remove Book"
    puts "4. Sort by ISBN"
    puts "5. Search Books by Title"
    puts "6. Search Books by Author"
    puts "7. Search Books by ISBN"
    puts "8. Exit"
    print "Enter your choice: "
    choice = gets.to_i

    case choice
    when 1
        inventory.list_books
    when 2
        print "Enter Title: "
        title = gets.chomp
        print "Enter Author: "
        author = gets.chomp
        print "Enter ISBN: "
        isbn = gets.chomp
        inventory.add_book(title, author, isbn)
    when 3
        print "Enter ISBN of the book you want to remove: "
        isbn = gets.chomp
        inventory.remove_book(isbn)
    when 4
        inventory.sort_books_by_isbn
        inventory.list_books
    when 5
        print "Enter title: "
        title = gets.chomp
        inventory.search_books_by_title(title)
    when 6
        print "Enter author: "
        author = gets.chomp
        inventory.search_books_by_author(author)
    when 7
        print "Enter ISBN: "
        isbn = gets.chomp
        inventory.search_books_by_isbn(isbn)
    when 8
        puts "Exiting program..."
        break
    else
        puts "Invalid Choice, Please try again!"
    end

    print "Do you want to continue? (1. Yes / 2. No): "
    continue_choice = gets.to_i
    break if continue_choice == 2
end
