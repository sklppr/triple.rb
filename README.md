triple.rb
=========

An implementation of the Triple algorithm for project schedules.

Schedules can be read from [PSPLIB](http://www.om-db.wi.tum.de/psplib/) files.

`Project#triple` then calculates earliest and latest starting times for each node.

Usage:

```ruby
project = Project.from_psp_file("psp100_1.sch")
project.max_duration = 200
puts project.triple
# => { 0 => { :es => 0, :ls => 0 }, 1 => { :es => 0, :ls => 109 }, ... }
```
