class S3Store
  require 'aws-sdk'

  def initialize(file,folder)
    @file = file
    @s3 = AWS::S3.new(  :region => REGION,
                        :access_key_id => ACCES_KEY_ID,
                        :secret_access_key => SECRET_ACCES_KEY
                      )
    @bucket = @s3.buckets[BUCKET+'/'+folder.to_s]
  end

  def store
    @obj = @bucket.objects[filename].write(@file.tempfile, acl: :private)
    self
  end

  def url
     @obj.public_url.to_s
  end

  private
  
  def filename
    @filename ||= @file.original_filename.gsub(/[^a-zA-Z0-9_\.]/, '_')
  end

end