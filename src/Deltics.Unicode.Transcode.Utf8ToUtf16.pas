
{$i deltics.unicode.inc}

  unit Deltics.Unicode.Transcode.Utf8ToUtf16;


interface

  uses
    Deltics.Unicode.Types;


  procedure _Utf8ToUtf16(var aUtf8: PUtf8Char; var aUtf8Count: Integer; var aUtf16: PWideChar; var aUtf16Count: Integer);



implementation

  uses
    Deltics.Unicode;


  procedure _Utf8ToUtf16(var aUtf8: PUtf8Char;
                         var aUtf8Count: Integer;
                         var aUtf16: PWideChar;
                         var aUtf16Count: Integer);
  var
    code: Codepoint;
    hi, lo: WideChar;
  begin
    while (aUtf8Count > 0) and (aUtf16Count > 0) do
    begin
      code := Unicode.Utf8ToCodepoint(aUtf8, aUtf8Count);

      if code > $ffff then
      begin
        if aUtf16Count = 1 then
          raise EMoreData.Create('%s requires a surrogate pair but only 1 widechar remains available in the destination buffer', [Unicode.Index(code)]);

        Unicode.CodepointToSurrogates(code, hi, lo);

        aUtf16^ := hi;
        Inc(aUtf16);
        aUtf16^ := lo;
        Inc(aUtf16);

        Dec(aUtf16Count, 2);
      end
      else
      begin
        aUtf16^ := WideChar(code);
        Inc(aUtf16);
        Dec(aUtf16Count);
      end;
    end;
  end;





end.
