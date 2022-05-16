Jekyll::Hooks.register [:pages, :posts], :post_render do |page|
  page.output = page.output.gsub(%r{^<p>(<img.+/assets/memes/.+)</p>$}, '<div class="meme">\1</div>')
end