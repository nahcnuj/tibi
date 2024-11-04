namespace Tibi

/--
`StringReader` is a structure to read strings from a stream, skipping whitespaces.
-/
structure StringReader where
  stream : IO.FS.Stream
  line : String

namespace StringReader

/--
`StringReader.ofStream` creates a StringReader from a `IO.FS.Stream`.
-/
def ofStream (stream : IO.FS.Stream) : StringReader :=
  { stream, line := "" }

private def fetch (reader : StringReader) : IO (Option StringReader) := do
  if reader.line.isEmpty then
    let line ← reader.stream.getLine
    if line.isEmpty then
      return none
    else
      return some { reader with line }
  else
    return reader

private def lookahead (reader : StringReader) : Char := reader.line.front

/--
`StreamReader.skipSpaces` skips leading whitespaces from the stream.
-/
partial def skipSpaces (reader : StringReader) : IO (Option StringReader) := do
  if let some reader ← reader.fetch then
    if reader.lookahead.isWhitespace then
      skipSpaces { reader with line := reader.line.dropWhile Char.isWhitespace }
    else
      pure reader
  else
    pure none

private partial def readRest (reader : StringReader) (ret : String) : IO (StringReader × String) := do
  if let some reader ← reader.fetch then
    if reader.lookahead.isWhitespace then
      pure (reader, ret)
    else
      let s := reader.line.takeWhile (not ∘ Char.isWhitespace)
      readRest { reader with line := reader.line.drop s.length } <| ret.append s
  else
    pure (reader, ret)

/--
`StreamReader.readString` reads the leading string not containing whitespaces from the stream.
-/
def readString (reader : StringReader) : IO (StringReader × String) := do
  reader.readRest ""
