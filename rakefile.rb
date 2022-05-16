require 'date'

namespace :gen do
  task :post do
    header = <<~MD
      ---
      layout: post
      title:  "%s"
      date:    #{Time.now}
      categories: jekyll update
      ---
    MD

    title = ARGV[1..]
    fname = Date.today.to_s + '-' + title.join('-') + '.md'

    if File.exist? "_posts/#{fname}"
      printf 'Exists, override? (y/n)'
      require 'io/console'
      STDIN.getch != 'y' && exit(1)
    end

    File.write("_posts/#{fname}", header % title.join(' ').capitalize)

    exit 0
  end
end
