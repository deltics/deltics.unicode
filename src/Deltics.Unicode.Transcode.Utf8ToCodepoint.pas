
{$i deltics.unicode.inc}

  unit Deltics.Unicode.Transcode.Utf8ToCodepoint;


interface

  uses
    Deltics.Unicode.Types;


  function _Utf8ToCodepoint(var aUtf8: PUtf8Char; var aMaxChars: Integer): Codepoint; overload;



implementation

  uses
    Deltics.Unicode;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function _Utf8ToCodepoint(var aUtf8: PUtf8Char;
                            var aMaxChars: Integer): Codepoint;
  const
    BYTE_OR_BYTES : array[FALSE..TRUE] of String = ('byte', 'bytes');
  var
    orgPtr: PUtf8Char;
    orgChars: Integer;
    numContinuationBytes: Integer;
    leadByte: Byte;
    continuationByte: Byte;
  begin
    result := 0;

    if aMaxChars < 1 then
      raise ENoData.Create('No Utf8 characters available');

    orgPtr    := aUtf8;
    orgChars  := aMaxChars;
    try
      leadByte := Byte(aUtf8^);
      Inc(aUtf8);
      Dec(aMaxChars);

      if (leadByte and $80) = $00 then
      begin
        result := Codepoint(leadByte);
        EXIT;
      end;

      if (leadByte and $e0) = $c0 then
        numContinuationBytes := 1
      else if (leadByte and $f0) = $e0 then
        numContinuationBytes := 2
      else if (leadByte and $f8) = $f0 then
        numContinuationBytes := 3
      else
        raise EInvalidEncoding.Create('0x%.2x is not a valid byte in Utf8', [leadByte]);

      if aMaxChars < numContinuationBytes then
        raise EMoreData.Create('%d continuation %s required, %d available', [
                                numContinuationBytes,
                                BYTE_OR_BYTES[numContinuationBytes > 1],
                                aMaxChars]);

      case numContinuationBytes of
        1: result  := ((leadByte and $1f) shl 6);
        2: result  := ((leadByte and $0f) shl 12);
        3: result  := ((leadByte and $07) shl 18);
      end;

      while numContinuationBytes > 0 do
      begin
        continuationByte := Byte(aUtf8^);

        if (continuationByte and $c0) <> $80 then
          raise EInvalidEncoding.Create('0x%.2x is not a valid continuation byte', [continuationByte]);

        Inc(aUtf8);
        Dec(aMaxChars);
        Dec(numContinuationBytes);

        result := result or ((continuationByte and $3f) shl (numContinuationBytes * 6));
      end;

    except
      aUtf8     := orgPtr;
      aMaxChars := orgChars;
      raise;
    end;
  end;




end.
