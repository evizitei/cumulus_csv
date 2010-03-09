module Cumulus
  module CSV
    BUCKET_NAME = "cumuluscsvtmp"     
    # DataFileManager is the gatekeeper for sending your data files to S3, and for iterating over them later. 
    #
    # In the constructor, It takes the same authentication parameters as aws-s3:
    # 
    #   DataFileManager.new(:access_key_id => 'abc',:secret_access_key => '123')  
    #
    # For storing your csv data file on S3, you need to setup a controller to send your uploaded files through this interface:
    #
    #   DataFileManager.new(connection_params).store_uploaded_file!(params[:uploaded_file])
    #
    # The file will be posted to S3 in a bucket set aside for this gem (it will be created upon connection if it doesn't exist already)
    # 
    # When you're ready to iterate over this csv file later in a background job (or wherever), you'll use this:
    #  
    #    DataFileManager.new(connection_params).each_row_of(name) {|row| #...whatever processing you need }
    #   
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