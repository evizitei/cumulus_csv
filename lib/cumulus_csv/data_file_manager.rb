module Cumulus
  module CSV
    BUCKET_NAME = "cumuluscsvtmp"
    class DataFileManager        
      attr_reader :bucket
      
      def initialize(connect_params)
        AWS::S3::Base.establish_connection!(connect_params)
        cache_bucket
      end  
      
      def store_uploaded_file!(uploaded_file)        
        name = File.basename(uploaded_file.original_filename)   
        AWS::S3::S3Object.store(name,uploaded_file.read,BUCKET_NAME)    
        return name
      end  
      
      def each_row_of(file_name) 
        data = AWS::S3::S3Object.value(file_name,BUCKET_NAME)
        ::CSV::Reader.parse(data).each{|row| yield row }
      end
      
    private
      def cache_bucket
        begin 
          @bucket = AWS::S3::Bucket.find(BUCKET_NAME)
        rescue AWS::S3::S3Exception
          AWS::S3::Bucket.create(BUCKET_NAME)      
          @bucket = AWS::S3::Bucket.find(BUCKET_NAME)
        end
      end
    end
  end
end