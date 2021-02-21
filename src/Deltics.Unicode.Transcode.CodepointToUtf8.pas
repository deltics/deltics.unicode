
{$i deltics.unicode.inc}

  unit Deltics.Unicode.Transcode.CodepointToUtf8;


interface

  uses
    Deltics.Unicode.Types;


  procedure _CodepointToUtf8(const aCodepoint: Codepoint; var aUtf8: PUtf8Char; var aMaxChars: Integer);


implementation

  uses
    Deltics.Unicode;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure _CodepointToUtf8(const aCodepoint: Codepoint;
                             var   aUtf8: PUtf8Char;
                             var   aMaxChars: Integer);
  var
    numContinuationBytes: Integer;
  begin
    case aCodepoint of
      $00..$7f        : begin
                          aUtf8^ := Utf8Char(aCodepoint);
                          Inc(aUtf8);
                          Dec(aMaxChars);
                          EXIT;
                        end;

      $80..$7ff       : begin
                          numContinuationBytes := 1;
                          aUtf8^ := Utf8Char($c0 or ((aCodepoint shr 6) and $1f));
                        end;

      $800..$ffff     : begin
                          numContinuationBytes := 2;
                          aUtf8^ := Utf8Char($e0 or ((aCodepoint shr 12) and $0f));
                        end;

      $10000..$10ffff : begin
                          numContinuationBytes := 3;
                          aUtf8^ := Utf8Char($f0 or ((aCodepoint shr 18) and $07));
                        end;
    else
      raise EInvalidCodepoint.Create('%s is not a valid codepoint', [Unicode.Ref(aCodepoint)]);
    end;

    if numContinuationBytes > aMaxChars then
      raise EUnicode.Create('Codepoint %s requires %d bytes to encode in Utf8 (capacity in buffer is %d)', [
                            Unicode.Ref(aCodepoint),
                            numContinuationBytes + 1,
                            aMaxChars]);

    Inc(aUtf8);
    Dec(aMaxChars);

    while numContinuationBytes > 0 do
    begin
      Dec(numContinuationBytes);
      aUtf8^ := Utf8Char($80 or ((aCodepoint shr (numContinuationBytes * 6)) and $3f));
      Inc(aUtf8);
      Dec(aMaxChars);
    end;
  end;




end.
