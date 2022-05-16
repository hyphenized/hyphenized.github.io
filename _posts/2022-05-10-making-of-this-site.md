---
layout: post
title:  Making of this site
date:    2022-05-10 20:13:51 -0500
categories: jekyll 
---

#### Where's all the JavaScript/React/Svelte/Vue/etc ?

This site has no JavaScript(besides the dark mode toggler of course).

_"But why?"_ you might ask, the main reason I chose to make it using HTML/CSS instead of using an static site generator like Gatsby or the like is that, nowadays most websites suffer of having unnecessary big bundles of JavaScript loading instead of what users actually visited the site for, content. 

Initially I wanted to make something shimmering that would showcase my skills/proficiency, probably with three.js, gsap and all that fancy stuff. However, including three.js alone would cause this website to load several times(6x~) slower! I chose to keep this stupid simple so that you, the reader/googlebot could save the most precious resource that you'll never recover, time (_probably battery, cpu cycles, mobile data and some other things as well_).

I think every developer should be mindful of the decisions they take, and not just do things because everyone else is doing them that way. That being said, there's nothing wrong with trying out new technologies. What is wrong, however, is creating a problem where none exists as an excuse to implement a solution.

![I should write something to describe this image](/assets/memes/programmer_move.jpg)


#### Kick starting the blog with Jekyll

I have never used Jekyll before, but it's very simple, you write some templates/layouts, then add some content in the form of markdown files and bang! There's a blog.

I would have enjoyed the process of getting everything ready much more had I not made a few mistakes along the way. I followed the quick start tutorial at Jekyll's and soon ran across an issue after trying to use a theme that I liked. 

At the moment of writing, you need version [jekyll@3.9.2](https://pages.github.com/versions/) for GitHub Pages to work. Unfortunately, the theme I chose was not compatible with Jekyll 4 and I did not realize this until I found out that the version 0.1 of the theme had been installed :chloe:. 

I then switched back to Jekyll 3.9.2 but later I realized that wasn't necessary because I could build my site locally and have GitHub pages serve that(or do the build step in a GH actions CI container).

Doing the build step through Github Pages was not an option if I wanted to use a custom plugin to embed the bttv emojis since [GH Pages runs Jekyll in safe mode](https://github.com/jekyll/jekyll/blob/v3.9.2/docs/_docs/plugins.md) (_which means no custom plugins_).

Anyway enough talk, lets begin.

<div style="text-align: center">

<img src="/assets/img/elizabethdevtools.jpg">
<em>This is where your data savings are going to</em>
</div>

## Picking a theme

I found a theme I liked at [https://jamstackthemes.dev/ssg/jekyll/](https://jamstackthemes.dev/ssg/jekyll/). That being said, it didn't work out of the box so if you're unable to get everything working the problem might either be your version of jekyll, the theme, or something else (I'd check in that order).

You can find some themes for code highlighting here:
[https://stylishthemes.github.io/Syntax-Themes/pygments/](https://stylishthemes.github.io/Syntax-Themes/pygments/) 
or, make a custom one [here](https://jwarby.github.io/jekyll-pygments-themes/builder.html):

## Adding Dark mode
The easiest (and quickest) way to add dark mode to your website would be to just add something like [watercss](https://watercss.netlify.app/).

However as you'll see, adding dark mode is a piece of cake without any external dependencies. You only need css variables, media queries that target `prefers-color-scheme` and a small script to allow your users to toggle between both themes.

We don't have to worry too much about browser support since right now [CSS Variables are supported by at least 94% of all browsers](https://caniuse.com/css-variables). The story is a bit different for `prefers-color-scheme` but for those cases, we can load the light theme by default and allow the user to change it manually.

{%highlight html%}
{%raw%}
<button id="toggler" type="button">TOGGLE</button>
<script>
  const themes = { dark: "🌙", light: "☀" };
  
  const defaultTheme = (() => {
    const saved = localStorage.getItem("theme");
    return saved || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  })();

  let currentTheme = defaultTheme;
  toggler.textContent = themes[currentTheme];

  const root = document.querySelector('html');
  root.classList.toggle(currentTheme);

  toggler.onclick = () => {
    const next = currentTheme == "light" ? 'dark' : 'light';
    root.classList.toggle(currentTheme);
    root.classList.toggle(next);

    currentTheme = next;
    toggler.textContent = themes[currentTheme];
    try { localStorage.setItem("theme",currentTheme) } 
    catch (err) {/* noop */}
  }
  window.onload = () => {root.classList.toggle("loaded")}
</script>
{%endraw%}
{%endhighlight%}

Styles I added/changed

{%highlight scss%}
@mixin dark-theme {
  --code-bg: #282a36;
  --bg: rgba(0, 0, 0, 0.9);
  --text: white;
  --link: #a0d86c;
  --link-2: #e2872c;
}

html {
  --code: #fff;
  --code-bg: #282a36;
  --text: #222;
}

@media (prefers-color-scheme: dark) {
  html:not(.light) {
    @include dark-theme();
  }
}
html.dark {
  @include dark-theme();
}

.dark {
  a {
    color: var(--link-2);
    &:visited {
      color: var(--link);
    }
  }
}

html.loaded body {
  transition: all 0.3s ease-in-out;
}
{%endhighlight%}
<br>
Note that we add a smooth transition between light-dark mode and only enable once the page has loaded. This is to prevent flashes of black/white before and after loading. It will also prevent transitions when entering the page  if a user _prefers dark mode_ but has already visited our site and chosen a theme.
## Writing our custom plugin
Adding custom plugins to Jekyll is fairly easy, just create a .rb file under the `_plugins` folder and you're ready to go.

Jekyll exposes hooks you can use to transform the output of your build, since we want to replace text matching :<span>hype</span>: for the corresponding HTML to embed :hype:, the following should do the trick:


{% highlight rb %}
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
{% endhighlight %}


The `post_convert` event tells Jekyll to run our block after the markdown has been converted to HTML but, before it is inserted into the layout. We register our transforming logic for both posts and pages that have been processed from markdown.

Next thing we'll need to add some emotes in order for our previous plugin to actually do something, we'll put these in a JSON file inside the `_data` folder so that we can access them within our plugin and later generate a page listing the current emojis.

{% highlight json %}

[
  {
    "src": "https://cdn.betterttv.net/emote/5f43037db2efd65d77e8a88f/2x",
    "id": "ratdance"
  },
]

{% endhighlight %}

{% highlight html %}
{% raw %}
# Emotes
<div style="display:flex; flex-wrap: wrap;">
{%- for item in site.data.emotes -%}
  <div style="width: 64px; padding: 0 1rem;">
    <img src="{{item.src}}">
    <p style="text-align: center">{{item.id}}</p>
  </div>
{% endfor %}
<div>

{% endraw %}
{% endhighlight %}

We can test that our emotes work after reloading Jekyll, we'll want to deploy our site after this, and can easily do so by running `jekyll build` and pushing the contents to a `gh-branch` within our repo. 

...And that's it for this post, it's indeed very interesting to see what you can achieve with so little using Jekyll. I am looking forward to customizing it more as this site's content grows.

:mega.exit: