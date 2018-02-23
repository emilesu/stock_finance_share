CarrierWave.configure do |config|
  config.storage             = :qiniu
  config.qiniu_access_key    = ENV["qiniu_access_key"]
  config.qiniu_secret_key    = ENV["qiniu_secret_key"]
  config.qiniu_bucket        = ENV["qiniu_bucket"]
  config.qiniu_bucket_domain = ENV["qiniu_bucket_domain"]
  config.qiniu_block_size    = 4*1024*1024
  config.qiniu_protocol      = "http"
  config.qiniu_async_ops       = "http://up.qiniu.com/" #七牛上传海外服务器,国内使用可以不要这行配置

end
