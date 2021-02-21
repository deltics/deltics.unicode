
{$i deltics.unicode.inc}

  unit Deltics.Unicode.Transcode.Utf16ToUtf8;


interface

  uses
    Deltics.Unicode.Types;


  procedure _Utf16ToUtf8(var aUtf16: PWideChar; var aUtf16Count: Integer; var aUtf8: PUtf8Char; var aUtf8Count: Integer);



implementation

  uses
    Deltics.Unicode;


  procedure _Utf16ToUtf8(var aUtf16: PWideChar;
                         var aUtf16Count: Integer;
                         var aUtf8: PUtf8Char;
                         var aUtf8Count: Integer);
  type
    TState = (BMP, LoSurrogate);
  var
    state: TState;
    hi: WideChar;
    code: CodePoint;
  begin
    hi    := #$0000;
    state := BMP;

    while (aUtf16Count > 0) and (aUtf8Count > 0) do
    begin
      case state of
        BMP         : begin
                        if Unicode.IsHiSurrogate(aUtf16^) then
                        begin
                          hi    := aUtf16^;
                          state := LoSurrogate;
                        end
//                      else if StrictEncoding and Unicode.IsLoSurrogate(aUtf16^) then
//                        raise EInvalidEncoding.Create('Orphan Low Surrogate');
                        else
                          Unicode.CodepointToUtf8(Codepoint(aUtf16^), aUtf8, aUtf8Count);

                        Inc(aUtf16);
                        Dec(aUtf16Count);
                      end;

        LoSurrogate : if Unicode.IsLoSurrogate(aUtf16^) then
                      begin
                        code := Unicode.SurrogatesToCodepoint(hi, aUtf16^);
                        Unicode.CodepointToUtf8(code, aUtf8, aUtf8Count);

                        Inc(aUtf16);
                        Dec(aUtf16Count);

                        state := BMP;
                      end;
//                      else if StrictEncoding then
//                        raise EInvalidEncoding.Create('Orphan High Surrogate');
      end;
    end;
  end;





end.
