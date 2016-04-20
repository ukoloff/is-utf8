#
# Handmade UTF-8 operations
#
rnd = require './random'
assert = require './assert'
valid8 = require './valid8'

#
# Convert to UTF-8
#
module.exports =
utf8 = (code)->
  code &= 0xFFFFFFFF
  # ASCII ?
  return [code] unless code >> 7
  buffer = []
  mask = 5
  loop
    buffer.unshift code & 0x3F | 0x80
    code >>>= 6
    break unless code >> mask--
  # First byte
  buffer.unshift code | 256 - (1 << mask+2)
  return buffer

#
# Check whether all bits in a sequence set correctly
#
utf8.valid =
valid = (buffer)->
  x = buffer.length
  return unless 0 < x < 8
  if 1==x
    # ASCII?
    return !(buffer[0] >> 7)
  # First byte
  return if buffer[0] >>> 7 - x != (1 << x) - 1 << 1
  for i in [2..x]
    # Continuation?
    return if buffer[i-1] >> 6 != 2
  true

#
# Make overlong sequence from valid one
#
utf8.overlong =
overlong = (buffer)->
  return unless valid buffer
  switch x = buffer.length
    when 1
      x = buffer[0]
      return [x >> 6 | 0xC0, x & 0x3F | 0x80]
    when 7
      return
  # Add first byte to multi-byte
  buffer = [].slice.call buffer
  x = 1 << 7 - x
  buffer[0] &= 0x7F + x
  buffer.unshift 0x100 - x
  buffer

#
# Generate all overlongs
#
utf8.overlongs = (code)->
  code = utf8 code if 'number'==typeof code
  code while code = overlong code

#
# Find codepoint for valid sequence
#
utf8.code = (buffer)->
  return unless valid buffer
  return buffer[0] if 1==buffer.length
  for n, i in buffer
    code = if i
      code << 6 | n & 0x3F
    else
      n & (1 << 7 - buffer.length) - 1
  code >>> 0  # Unsigned int

#
# Generate intervals array
#
utf8.ranges =
ranges = (array)->
  array
  .map (x)->
    if x.bytes
      x = x.bytes
      x = x * 5 + 1 + Number x == 1
    if 'number' == typeof x
      max: (2 << x - 1) - 1 >>> 0
    else if !x
      skip: true
    else
      x
  .reduce (ranges, x, i)->
    if i > 1
      prev = ranges[ranges.length-1].b
    else
      prev = ranges
      ranges = []
    ranges.push
      a: prev
      b: x
    ranges
  .filter (x)->
    !x.a.skip and !x.b.skip
  .map (x)->
    min: x.a.min ? x.a.max + 1
    max: x.b.max ? x.b.min - 1

#
# Ranges used for UTF-8 random strings
#
bits = ranges [min: 0, {bytes: 1}, 8, {bytes: 2},
  min: 0xD800, false, max: 0xDFFF, {bytes: 3}, max: 0x10FFFF]

#
# Generate random UTF-8 buffer
#
pick = rnd.pick
range = rnd.range

utf8.random =
random = (n = 16)->
  r = []
  r = r.concat utf8 range pick bits for i in [1..n]
  r

#
# Wrap fragment with random strings and test
#
utf8.test4 = (good, buffer)->
  buffer = new Buffer buffer  unless Buffer.isBuffer buffer
  for z in [0..3]
    x = [buffer]
    x.unshift new Buffer random 27  if z & 1
    x.push new Buffer random 27  if z & 2
    x = valid8 Buffer.concat x
    x = !x unless good
    assert x
  return
