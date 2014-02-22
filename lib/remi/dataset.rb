module Remi

  require 'msgpack'
  require 'zlib'

  def datastep(*dataset)

    raise "datastep called, no block given" if not block_given?

    # All this needs to do is open and close the dataset
    puts "-" * 5 + "DATASTEP" + "-" * 5
    puts "All this needs to do is open and close each dataset given"

    dataset.each do |ds|
      ds.open
    end

    yield *dataset

    dataset.each do |ds|
      ds.close
    end


  end


  class Dataset

    def initialize(datalib,name,lib_options)

      # Initialize should check to see if dataset exists
      # If so, read variables and other dataset options
      # If not, initialize an empty dataset

      @datalib = datalib
      @name = name

      @header_file_full_path = ""
      @data_file_full_path = ""

      if lib_options.has_key?(:directory)

        @header_file_full_path = File.join(lib_options[:directory][:dirname],"#{@name}.hgz")
        @data_file_full_path = File.join(lib_options[:directory][:dirname],"#{@name}.rgz")

      end


      # VARIABLES - will be their own object momentarily, hash for now
      @vars = {}

    end


    # Variables get evaluated in a module to separate the namespace
    def define_variables(&b)

      @vars = Variables.evaluate_block_vars(@vars,&b)
      puts to_s

    end

    # Variable accessor
    def [](varname)
      @vars[varname][:value]
    end

    # Variables assignment
    def []= varname,value
      @vars[varname][:value] = value
    end



    def open

      # Open should put a lock on the dataset so that further
      # calls to datalib.dataset_name return the same object
      
      puts "-Opening dataset-"
      puts "I will open #{@header_file_full_path} and #{@data_file_full_path}"


    end

    def close

      puts "-Closing dataset-"

    end



    def output

      puts "--OUTPUT--"

      @vars.each do |key,value|
        puts "#{key} => #{value[:value]}"
      end

    end



    def to_s

      msg = "\n" * 2
      msg << "-" * 4 + "DATASET" + "-" * 4 + "\n"
      msg << "This is dataset #{@name} <#{self.object_id}> in library #{@datalib}\n"
      msg << "\n"
      msg << "-" * 3 + "VARIABLES" + "-" * 3 + "\n"

      @vars.each do |key,value|
        msg << "#{key} => #{value}\n"
      end

      msg

    end

  end
end



=begin Not really thought out, but it did some stuff that might want to borrow
  class Dataset

    def initialize
      @variables = {}
      @row = {} # I do want row to be an array, but use a has for the moment
         # or maybe not, maybe I just want the data output to file to be array, internally it can be a hash
    end


    def open(full_path)

      raw_file = File.open(full_path,"w")
      @file = Zlib::GzipWriter.new(raw_file)

    end

    def close

      @file.close

    end


    def add_variable(varname,varmeta)

      tmpvarlist = @variables.merge({ varname => varmeta })

      if not tmpvarlist[varname].has_key?(:type)
        raise ":type not defined for variable #{varname}"
      end

      @variables = tmpvarlist
      @row[varname] = nil

    end



    def []=(varname,value)
      if @row.has_key?(varname)
        @row[varname] = value
      else
        raise "Variable '#{varname}' not defined"
      end
    end



    def [](varname)
      @row[varname]
    end



    def output

      printf "|"
      @row.each do |key,value|
        printf "#{key}=#{value}|"
      end
      printf "\n"

      @file.puts @row.to_msgpack

  #    puts "#{@row.inspect}"
    end

  end

end
=end




=begin
def serialize_msgpack(in_filename,out_filename,columns,debug=false)

  file = File.open(out_filename,"w")
  gz = Zlib::GzipWriter.new(file)


  sum = 0
#  CSV.open(in_filename, "r", { :headers => true } ) do |rows|
  CSV.open(in_filename, "r") do |rows|


    rows.each do |row|
      puts "row: #{row.inspect}" if debug
      puts "row is class #{row.class}" if debug
      puts row.to_json if debug
      gz.puts row.to_msgpack
      sum = sum + row[columns[:physical_cases]].to_f
      line_number = $.
      puts "#{line_number}" if line_number % 50000 == 0
    end

  end
  puts "Physical_Cases: sum = #{sum}"

  gz.close

end



def deserialize_msgpack(in_filename,columns)

  sum = 0
  File.open(in_filename) do |file|

    gz = Zlib::GzipReader.new(file)

    gz.each do |row_msgpack|
      row = MessagePack.unpack(row_msgpack.chomp)
      sum += row[columns[:physical_cases]].to_f
    end

    gz.close

  end
  puts "Physical_Cases: sum = #{sum}"


end
=end
