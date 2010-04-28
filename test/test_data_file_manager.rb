require 'helper'

class TestDataFileManager < Test::Unit::TestCase 
  context "Test" do       
    setup do
      nueter_aws!
      @auth_hash = {:access_key_id => 'abc',:secret_access_key => '123'}
    end
  
    context "Infrastructure" do
      should "connect to s3 at creation" do
        AWS::S3::Base.expects(:establish_connection!).with(@auth_hash)
        DataFileManager.new(@auth_hash)
      end
  
      should "cache cumulus bucket if it already exists" do
        AWS::S3::Bucket.expects(:create).times(0)
        AWS::S3::Bucket.stubs(:find).with(BUCKET_NAME).returns(AWS::S3::Bucket.new(:name=>BUCKET_NAME))
        manager = DataFileManager.new(@auth_hash)  
        assert_equal AWS::S3::Bucket, manager.bucket.class 
      end
  
      should "create new cumulus bucket if it does not yet exist" do
        AWS::S3::Bucket.expects(:create).times(1)
        AWS::S3::Bucket.stubs(:find).with(BUCKET_NAME).raises(AWS::S3::S3Exception).then.returns(AWS::S3::Bucket.new(:name=>BUCKET_NAME))
        manager = DataFileManager.new(@auth_hash)
        assert_equal AWS::S3::Bucket, manager.bucket.class
      end     
      
      should "parse out extra config keys" do 
        AWS::S3::Base.expects(:establish_connection!).with({:access_key_id => 'abc',:secret_access_key => '123'})
        DataFileManager.new(@auth_hash.merge({:extra_key=>"extra_value"}))
      end
    end    
  
    context "Uploaded File" do           
      setup do         
        @uploaded_file = stub("uploaded_file")
        @uploaded_file.stubs(:original_filename).returns("/long/path/to/some_name.csv")
        @uploaded_file.stubs(:read).returns("file data galore")
      end
    
      should "be stored by key" do   
        manager = DataFileManager.new(@auth_hash)   
        AWS::S3::S3Object.expects("store").with("some_name.csv","file data galore",BUCKET_NAME)
        assert_equal "some_name.csv",manager.store_uploaded_file!(@uploaded_file)
      end
    end  
    
    context "Stored csv file" do    
      should "be iterated over row by row" do    
        AWS::S3::S3Object.expects(:value).with("some_name.csv",BUCKET_NAME).returns("1,2,3\nA,B,C\nx,y,z\n")
        manager = DataFileManager.new(@auth_hash)
        results = []
        manager.each_row_of("some_name.csv") do |row|  
          results << row 
        end             
        assert_equal ["1","2","3"],results.first
        assert_equal ["x","y","z"],results.last
      end
    end
                          
  end
  def nueter_aws!  
    AWS::S3::Base.stubs(:establish_connection!)
    AWS::S3::Bucket.stubs(:find)
    AWS::S3::Bucket.stubs(:create)
  end
end
