#
# Maximum length allowed
# Can be set to 5 or 6 (or to 2 or 3)
#
@maxBytes = 4

#
# Validation itself
#
@isValidUTF8 = (buffer)=>
  mode = 0  # First byte
  for n, i in buffer
    if mode
      # Continuation: 10xxxxxx
      return if 0xC0 != (0xC0 & n)
      code = code<<6 | n & 0x3F
      continue if --mode
      # Overlong?
      return unless code >> bits
      continue

    # ASCII: 0xxxxxxx
    continue unless n & 0x80
    # 8 bytes, 7 bytes (avoid 64-bit math), overlong 2 bytes
    return if n in [0xFF, 0xFE, 0xC0]
    # Continuation: 10xxxxxx
    return unless n & 0x40
    code = 0
    mode = 1
    mask = 0x20
    while n & mask
      mask >>= 1
      mode++
    return if mode >= @maxBytes
    bits = 5*mode + 1

  # Unfinished
  return if mode
  # Valid!!!
  true
