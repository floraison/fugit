---
name: Issue Report
about: Create a report to help us help you
title: ''
labels: ''
assignees: ''

---

## Issue description

A clear and concise description of what the issue is. (There is an example of a carefully filled issue at https://github.com/floraison/fugit/issues/18)

## How to reproduce

The simplest piece of code that reproduces the issue, for example:
```ruby
require 'fugit'
c = Fugit.parse('0 9 29 feb *')
p c.previous_time
```
Or else, please describe carefully what to do to see a live example of the issue.

## Error and error backtrace (if any)

(This should look like:
```
ArgumentError: found no time information in "0-65 * * * *"
  from /home/john/w/fugit/lib/fugit/parse.rb:32:in `do_parse'
  from ...
  from /home/john/.gem/ruby/2.3.7/gems/bundler-1.16.2/lib/bundler/vendor/thor/lib/thor/base.rb:466:in `start'
  from /home/john/.gem/ruby/2.3.7/gems/bundler-1.16.2/lib/bundler/cli.rb:18:in `start'
  from /home/john/.gem/ruby/2.3.7/gems/bundler-1.16.2/exe/bundle:30:in `block in <top (required)>'
  from /home/john/.gem/ruby/2.3.7/gems/bundler-1.16.2/lib/bundler/friendly_errors.rb:124:in `with_friendly_errors'
  from /home/john/.gem/ruby/2.3.7/gems/bundler-1.16.2/exe/bundle:22:in `<top (required)>'
  from /home/john/.gem/ruby/2.3.7/bin/bundle:22:in `load'
  from /home/john/.gem/ruby/2.3.7/bin/bundle:22:in `<main>'
```
)

## Expected behaviour

A clear and concise description of what you expected to happen.

## Context

Please replace the content of this section with the output of the following commands:
```
uname -a
bundle exec ruby -v
bundle exec ruby -e "p [ :env_tz, ENV['TZ'] ]"
bundle exec ruby -r et-orbi -e "EtOrbi._make_info"
bundle exec ruby -r fugit -e "p Fugit::VERSION"
```

(It's supposed to look like
```
Darwin pollux.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Dec 20 21:47:19 PST 2018;
  root:xnu-4570.71.22~1/RELEASE_X86_64 x86_64
ruby 2.3.7p456 (2018-03-28 revision 63024) [x86_64-darwin17]
[:env_tz, nil]
(secs:1553304485.185308,utc~:"2019-03-23 01:28:05.18530797958374023",ltz~:"JST")
(etz:nil,tnz:"JST",tziv:"2.0.0",tzidv:"1.2018.9",rv:"2.3.7",rp:"x86_64-darwin17",win:false,
  rorv:nil,astz:nil,eov:"1.1.7",eotnz:#<TZInfo::TimezoneProxy: Asia/Tokyo>,eotnfz:"+0900",
  eotlzn:"Asia/Tokyo",eotnfZ:"JST",debian:nil,centos:nil,osx:"zoneinfo/Asia/Tokyo")
"1.3.9"
```
)

## Additional context

Add any other context about the problem here.

