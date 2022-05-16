---
layout: post
title: Thoughts on React
date: 2022-05-12 14:13 -0500
categories: react
---

After using react for a while I have started to find very annoying the fact that you need a lot of boilerplate code to achieve somewhat basic operations (which does not happen in other frameworks). For instance in Svelte you can define a variable `counter` to store your state, modify it directly and everything works fine out of the box. But, in React you would have to call useState(), deconstruct an array to get a reference to both a possibly stale value (unless you store it in a ref, then you have some other problems) and an updater function, not to say if you have custom logic handling you might need to memoize and wrap this updater inside a handler function, unless, you use classes with instance bound functions. But apparently, besides the slightly higher footprint they have, in some cases they could end up increasing the amount of boilerplate code too. Svelte is not perfect either so pick your poison.

#### Why do you work with React then?

Gotta know the rules to break 'em. :haHAA:
