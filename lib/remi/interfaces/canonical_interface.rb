module Remi
  module Interfaces

    # Public: The canonical interface is an interface with a file on the local system.
    # Data is written to the file by serializing the row objects using MessagePack and
    # then compressed to save space and IO.  Each data set is a collection of two files.
    # One is a header that stores all of the metadata about a data set and the other
    # is a detail file that stores all of the data.
    class CanonicalInterface < BasicInterface

      # Public: Initializes a CanonicalInterface.
      #
      # data_lib      - An instance of a DataLib object that this data set belongs to.
      # data_set_name - The name of the data set, which translates to the name of the file created.
      def initialize(data_lib, data_set_name)
        super(data_lib, data_set_name)
      end

      # Public: Gets the header file object
      attr_reader :header_file

      # Public: Gets the data file object
      attr_reader :data_file

      # Public: Opens the file for writing.
      #
      # Returns nothing.
      def open_for_write
        @mode = :write
        self.eof_flag = false
        open_header_for_write
        open_data_for_write
      end

      # Public: Opens the file for reading.
      #
      # Returns nothing.
      def open_for_read
        @mode = :read
        self.eof_flag = false
        open_header_for_read
        open_data_for_read
      end

      # Public: Returns the full path to the header file.
      def header_file_full_path
        component_file_full_path('hgz')
      end

      # Public: Returns the full path to the data file.
      def data_file_full_path
        component_file_full_path('rgz')
      end


      # Public: Reads and returns the data set metadata.
      def read_metadata
        open_header_for_read
        metadata = YAML.load(@header_stream.read)
        close_header_file

        set_key_map metadata[:variable_set]
        metadata
      end

      # Public: Sets and returns the key map to use during read/write.
      def set_key_map(key_map)
        @key_map = key_map
      end


      # Public: Write the data set metadata.
      def write_metadata(variable_set: nil)
        metadata = { :variable_set => variable_set }
        @header_stream.write(metadata.to_yaml).flush
      end


      # Public: Reads a row from the file into the active row.
      #
      # Returns a Row instance.
      def read_row
        @prev_read ||= @data_stream.read
        @row ||= Row.new(@prev_read, key_map: @key_map)

        begin
          this_read = @data_stream.read
        rescue EOFError
          self.eof_flag = true
          @row.last_row = true
        end

        @row.set_values(@prev_read)
        @prev_read = this_read

        @row
      end


      # Public: Writes a row to the data file.
      #
      # row - A Row instance to be written.
      #
      # Returns nothing.
      def write_row(row)
        @counter ||= 0
        @counter += 1
        @data_stream.write(row.to_a)
        @data_stream.flush if @counter % 10000 == 0
      end

      # Public: Closes the header and data files.
      #
      # Returns nothing.
      def close
        close_header_file
        close_data_file
      end

      # Public: Returns true if the file representing the data set exists.
      def data_set_exists?
        Pathname.new(header_file_full_path).exist?
      end

      # Public: Creates a new file represending an empty data set.
      #
      # Returns nothing.
      def create_empty_data_set
        open_for_write
        close
      end

      # Public: Deletes the header and data files.
      #
      # Returns nothing.
      def delete
        File.delete(header_file_full_path)
        File.delete(data_file_full_path)
      end




      private

      # Private: Opens the header file for writing.
      def open_header_for_write
        @header_file = Zlib::GzipWriter.new(File.open(header_file_full_path,"w"))
        @header_stream = MessagePack::Packer.new(@header_file)
      end

      # Private: Opens the data file for writing.
      def open_data_for_write
        @data_file = Zlib::GzipWriter.new(File.open(data_file_full_path,"w"))
        @data_stream = MessagePack::Packer.new(@data_file)
      end

      # Private: Opens the header file for reading.
      def open_header_for_read
        @header_file = Zlib::GzipReader.new(File.open(header_file_full_path,"r"))
        @header_stream = MessagePack::Unpacker.new(@header_file)
      end

      # Private: Opens the data file for reading.
      def open_data_for_read
        @data_file = Zlib::GzipReader.new(File.open(data_file_full_path,"r"))
        @data_stream = MessagePack::Unpacker.new(@data_file)
      end

      # Private: Returns the full path to either the header or data file.
      def component_file_full_path(component)
        File.join(@data_lib.dir_name,"#{@data_set_name}.#{component}")
      end

      # Private: Closes the header file.
      def close_header_file
        @header_file.close unless @header_file.closed?
      end

      # Private: Closes the data file.
      def close_data_file
        @data_stream.flush if @mode == :write
        @data_file.close unless @data_file.closed?
      end

    end
  end
end
