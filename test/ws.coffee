###
Tests borrowed from:
https://github.com/websockets/ws/blob/master/test/Validation.test.js
###
assert = require './assert'
valid8 = require './valid8'

describe 'isValidUTF8', ->
  it 'should return true for a valid utf8 string', ->
    assert valid8 Buffer.from '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Quisque gravida mattis rhoncus.
Donec iaculis, metus quis varius accumsan,
erat mauris condimentum diam, et egestas erat enim ut ligula.
Praesent sollicitudin tellus eget dolor euismod euismod.
Nullam ac augue nec neque varius luctus.
Curabitur elit mi, consequat ultricies adipiscing mollis, scelerisque in erat.
Phasellus facilisis fermentum ullamcorper.
Nulla et sem eu arcu pharetra pellentesque.
Praesent consectetur tempor justo, vel iaculis dui ullamcorper sit amet.
Integer tristique viverra ullamcorper.
Vivamus laoreet, nulla eget suscipit eleifend,
lacus lectus feugiat libero, non fermentum erat nisi at risus.
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Ut pulvinar dignissim tellus, eu dignissim lorem vulputate quis.
Morbi ut pulvinar augue.
'''.replace /\s+/, ' '

  it 'should return false for an erroneous string', ->
    assert not valid8 Buffer.from [
      0xce, 0xba, 0xe1, 0xbd, 0xb9, 0xcf, 0x83, 0xce, 0xbc, 0xce,
      0xb5, 0xed, 0xa0, 0x80, 0x65, 0x64, 0x69, 0x74, 0x65, 0x64]

  it 'should return true for valid cases from the autobahn test suite', ->
    assert valid8 Buffer.from '\xf0\x90\x80\x80'
    assert valid8 Buffer.from [0xf0, 0x90, 0x80, 0x80]

  it 'should return false for erroneous autobahn strings', ->
    assert not valid8 Buffer.from [0xce, 0xba, 0xe1, 0xbd]
