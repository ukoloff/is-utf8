fs = require 'fs'
path = require 'path'
assert = require 'assert'
valid8 = require '..'
random = require './random'

buffers = []

test = (buffer)->
  buffer = new Buffer buffer unless buffer instanceof Buffer
  buffers.push buffer = buffer
  assert valid8 buffer

describe 'Empty buffer', ->
  it 'is valid', ->
    test 0

describe 'ASCII', ->
  it 'is valid', ->
    for i in [0..0x7F]
      test Buffer [i]

    test [0x7F..0]

describe 'Cyrillic', ->
  it 'is valid', ->

    test 'Однажды в студёную зимнюю пору'

describe 'Glass', ->
  it 'is eatable', ->

    test fs.readFileSync path.join __dirname, 'glass.html'

describe 'Coffee', ->
  it 'is drinkable', ->

    test fs.readFileSync __filename

describe "Buffer", ->
  it "is inspected entirely", ->
    for b in buffers
      assert not valid8 Buffer.concat [b, new Buffer [random 128, 255]]
