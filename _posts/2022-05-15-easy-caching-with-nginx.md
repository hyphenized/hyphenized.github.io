---
layout: post
title: Improving your Rails app load speeds
categories: http nginx caching speed
date: 2022-05-15 00:25 -0500
---
### 1. Add a CDN on top of your application
Content delivery networks speed up your application by distributing copies(cached data) of your application responses from locations closer to your users.

Using a Content Delivery Network should add a small overhead for handling dynamic content requests (_since these can't be cached_) and cache misses (_which happen when the CDN servers don't have a cached response yet and have proxy the request to your server_). However, it's almost unnoticeable since CDNs tipically use special kind of servers called _edge servers_ which are **very close** to your users. Consequently, the data coming back to your users spends less time in transit due to requiring less hops to reach their final destination. CDNs greatly reduce overall loading time by caching your application assets/responses across edge servers. 

CDNs also have the benefit of providing protection against increased bursts of traffic (in case your application becomes really popular) and DDoS protection. Some of them also offer additional features like compression, to further optimize your assets delivery.

Use something like Cloudfront/Cloudflare. Cloudflare has a generous free tier(Even if you're planning on build a SaaS). They also have good resources on this topic.

### 2. Reduce connection latency between server/clients
No matter how optimized your application assets are or how fast your internet connection is, when it comes to downloading a bunch of files RTT(Round trip time) is what matters the most. If a request sent from your users device takes as much as 200 ms to reach your server then your users will leave your page before it even finishes loading.

You might argue that your internet speed is very fast, and it might be, but in order to download multiple assets your users browser might need to establish multiple connections at the same time. If each one of those had a RTT of 200ms then a full page load could end up taking around ~1 second for a small website with 5 assets :lag:. It's actually much more complicated than that but the point is that for most users [latency has a bigger impact than bandwith](https://community.f5.com/t5/technical-articles/rtt-round-trip-time-aka-ndash-why-bandwidth-doesn-rsquo-t-matter/ta-p/275342). 

If you're interested, this is a good read on latency: [It's the latency, stupid](http://www.stuartcheshire.org/rants/latency.html).

When hosting on a VPS, be sure to choose a datacenter that's closest to your target audience.

### 3. Delegate static assets serving to a web server
Rails **should not** be handling static asset requests. Ruby is a beautiful language, very fast to code software in, but not as fast to run it. To add to that, the more time your Rails server spends processing requests for static assets, the less it will be able to focus on actually running your application's logic.

Use something like nginx, there are faster web servers around nowadays but I suspect you should be able to get started quickly. Since most people are familiar with it, you should also be able to get help fast if you have issues while setting it up.

### 4. Use HTTP3/2.0
One of the greatest improvements of [HTTP 2.0](https://web.dev/performance-http2/) is request multiplexing, which allows sending multiple requests/responses over a single connection. This eliminates the need for reducing requests with hacks like asset concatenation and image sprites.

HTTP 2.0 is supported by most (if not all) browers nowadays and fully backwards compatible with HTTP 1.1 so there's very little reason for not including support for it.

HTTP3/ HTTP over QUIC is the newest, hotest thing around and it works much faster than HTTP 2 but browser support is still very poor. That being said, if you want to play with it and nginx just follow [this guide](https://github.com/cloudflare/quiche/tree/master/nginx) and remember that QUIC works over UDP so you'll have to unblock that if you're behind a firewall.

#### How do I know which protocol I am using?
Check the network panel on your browser devtools, enable the protocol column and check it's value, on Chrome the protocol column displays h3 for HTTP3.

### 5. Optimize, bundle and minify assets
Most, if not all things under this point are probably covered by something like pagespeed insights. What pagespeed won't tell you(_nor should it have to_) is that you shouldn't serve polyfills for promises if your web application requires devices to support something like WebGL(It doesn't make much sense). Specifying target browsers will reduce the amount of polyfills and prefixes shipped within your JavaScript/CSS bundles, which in turn will greatly improve load speeds :hype:.

For images/SVGs/videos it depends, sometimes, if the asset is small enough it might make more sense to base64 embed it to prevent an extra request. In the past, before HTTP 2.0 developers would often generate a sprite to load a bunch of small images within a single request but, you probably don't won't need to do that nowadays. 

Use modern image formats like WebP and include responsive variants, this might be hard to achieve if you have to handle a lot of user submitted images but it is doable. You'll likely want to enable brotli/gzip compression for text-like assets as well.

Finally, for videos it's a good idea to focus on bitrate and compression(codec). WebM(VP8/VP9) with a bitrate of at least 3 Mbps has worked well for me.

### 6. Use conditional gets and good cache directives
Within your application controllers, you can easily set etags and cache expires using helpers like `fresh_when`/`stale_if` to minimize the resources spent by your server to process the request.
There's also partial/fragment caching but I won't cover that here.

Make sure you don't cache dynamic content requests outside of Rails. Otherwise you risk having a user see another user's logged in page (unless that's what you want :myaa:)

### Finally, make sure to use something like curl to test that everything is working the way you expect it to.