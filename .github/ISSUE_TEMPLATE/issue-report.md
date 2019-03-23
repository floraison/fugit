---
name: Issue Report
about: Create a report to help us help you
title: ''
labels: ''
assignees: ''

---

**Describe the issue**
A clear and concise description of what the issue is.

**To Reproduce**
The simplest piece of code that reproduces the issue, for example:
```ruby
require 'fugit'
c = Fugit.parse('0 9 29 feb *')
p c.previous_time
```
Or else, please describe carefully what to do to see a live example of the issue.

**Expected behavior**
A clear and concise description of what you expected to happen.

**Context**
Please paste here the output of the following commands:
```
uname -a
bundle exec ruby -v
bundle exec ruby -r et-orbi -e "EtOrbi._make_info"
```

(It's supposed to look like
```
Darwin pollux.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Dec 20 21:47:19 PST 2018;
  root:xnu-4570.71.22~1/RELEASE_X86_64 x86_64
ruby 2.3.7p456 (2018-03-28 revision 63024) [x86_64-darwin17]
(secs:1553304485.185308,utc~:"2019-03-23 01:28:05.18530797958374023",ltz~:"JST")
(etz:nil,tnz:"JST",tziv:"2.0.0",tzidv:"1.2018.9",rv:"2.3.7",rp:"x86_64-darwin17",win:false,
  rorv:nil,astz:nil,eov:"1.1.7",eotnz:#<TZInfo::TimezoneProxy: Asia/Tokyo>,eotnfz:"+0900",
  eotlzn:"Asia/Tokyo",eotnfZ:"JST",debian:nil,centos:nil,osx:"zoneinfo/Asia/Tokyo")
```
)

**Additional context**
Add any other context about the problem here.
