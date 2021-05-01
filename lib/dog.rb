class Dog
    attr_accessor :name, :breed, :id

    def initialize(hash, id = nil)
        @name = hash[:name]
        @breed = hash[:breed]
        @id = id
    end
    
    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs ( id INT PRIMARY KEY, name TEXT, breed TEXT);")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", @name, @breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    # DB[:conn].execute("")
    def self.create(hash)
        Dog.new(hash).save
    end

    def self.new_from_db(attr_arr)
        hash = {
            :name => attr_arr[1],
            :breed => attr_arr[2]
        }
        dog = Dog.new(hash, attr_arr[0])
    end

    def self.find_by_id(id)
        self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten)
    end

    def self.find_or_create_by(attribute_hash)
        sql = <<-SQL
        SELECT * from dogs
        WHERE name == ? AND breed == ?
        ORDER BY name
        LIMIT 1
        SQL
        dog = DB[:conn].execute(sql, attribute_hash[:name], attribute_hash[:breed])
        # binding.pry
        if !dog.empty?
            dog_info = dog[0]
            dog_hash = {
                :name => dog_info[1],
                :breed => dog_info[2]
            }
            dog = Dog.new(dog_hash, dog_info[0])
        else
            dog = self.create(attribute_hash)
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name == ?
        LIMIT 1
        SQL
        self.new_from_db(DB[:conn].execute(sql, name).flatten)

    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ?
        WHERE ID == ?
        SQL
        DB[:conn].execute(sql, @name, @breed, @id)
        # sql = <<-SQL
        # UPDATE dogs SET breed = ?
        # WHERE ID == ?
        # SQL
        # DB[:conn].execute(sql, @breed, @id)
    end

end
