---
layout: post
title: Thoughts on React
date: 2022-05-12 14:13 -0500
categories: react
---

Having used React for a while I've started to find annoying the amount of boilerplate code that you need to achieve basic operations (which does not happen in other frameworks). For instance in Svelte you can define a variable `counter` to store your state, modify it directly and everything works fine out of the box. But, in React you would have to call useState(), deconstruct an array to get a reference to both a possibly stale value (unless you store it in a ref, then you have some other problems) and an updater function, not to say if you have custom logic handling you might also need to memoize and wrap this updater inside a handler function. 

You could get around this last point if you stick to class components but apparently, besides the slightly higher footprint that they have, in some cases they could end up increasing the amount of boilerplate code too. 

For what is worth, I am not saying Svelte is perfect (because it is not) but, I think developer happiness matters too!

#### Why do you work with React then?

Gotta know the rules to break 'em. :haHAA:
