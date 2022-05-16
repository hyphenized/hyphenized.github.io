cache = {}

def to_dict(list)
  list.each_with_object({}) do |hash, acc|
    id, src = hash.values_at("id", "src")
    acc[id] = src
  end
end

embed_emotes = ->(page) {
  emotes = (cache['emotes'] ||= to_dict(Jekyll.sites[0].data['emotes']))

  page.content = page.content.gsub(/:(?<variant>\w+\.)?(?<id>\w+):/) do |match|
    id, variant = Regexp.last_match.values_at("id", "variant")

    if emotes.key?(id)
      cls = 'bttv'
      cls += ' mega' if variant == 'mega.'
      %(<img class="#{cls}" src="#{emotes[id]}">)
    else
      match
    end
  end
}

Jekyll::Hooks.register %i[posts pages], :post_convert, &embed_emotes
