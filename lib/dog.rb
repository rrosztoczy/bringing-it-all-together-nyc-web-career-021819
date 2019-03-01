
class Dog
    attr_accessor :id, :name, :breed

    def initialize(attributes = {})
        self.name = attributes[:name]
        self.breed = attributes[:breed]
        self.id = nil
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        if self.id != nil
            self.update
        else
            DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def self.create(attributes = {})
        dog = Dog.new(attributes)
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL

        new_dog_data = DB[:conn].execute(sql, id).flatten
        new_dog = Dog.new(name: new_dog_data[1], breed: new_dog_data[2])
        new_dog.id = new_dog_data[0]
        new_dog
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
        if !dog.empty?
            new_dog = Dog.new({:name => dog[1], :breed => dog[2]})
            new_dog.id = dog[0]
            new_dog
        else
            new_dog = Dog.create({:name => name, :breed => breed})
            new_dog
        end
    end

    def self.new_from_db(arguments)
        puts arguments.inspect
        new_dog = Dog.create({:name => arguments[1], :breed => arguments[2]})
        new_dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL

        new_dog_data = DB[:conn].execute(sql, name).flatten
        new_dog = Dog.new(name: new_dog_data[1], breed: new_dog_data[2])
        new_dog.id = new_dog_data[0]
        new_dog
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end

end
