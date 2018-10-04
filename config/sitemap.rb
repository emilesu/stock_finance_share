# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://localhost:3000"

SitemapGenerator::Sitemap.create do

  add root_path

  add welcome_about_path, :changefreq => "weekly"

  add courses_path, :changefreq => "daily"

  add videos_path, :changefreq => "daily"

  Post.find_each do |post|
    add course_post_path(post.course, post), :lastmod => post.updated_at
  end

  Video.find_each do |video|
    add video_path(video), :lastmod => video.updated_at
  end

  Stock.find_each do |stock|
    add stock_path(stock), :changefreq => 'monthly', :lastmod => stock.updated_at
  end

  UsStock.find_each do |us_stock|
    add us_stock_path(us_stock), :changefreq => 'monthly', :lastmod => us_stock.updated_at
  end

  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
end
