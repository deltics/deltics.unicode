
{$i deltics.unicode.inc}

  unit Deltics.Unicode.Transcode.Utf16ToUtf8;


interface

  uses
    Deltics.Unicode.Types;


  procedure _Utf16BeToUtf8(var aUtf16: PWideChar; var aUtf16Count: Integer; var aUtf8: PUtf8Char; var aUtf8Count: Integer);
  procedure _Utf16LeToUtf8(var aUtf16: PWideChar; var aUtf16Count: Integer; var aUtf8: PUtf8Char; var aUtf8Count: Integer);



implementation

  uses
    Deltics.Unicode;


  procedure _Utf16BeToUtf8(var aUtf16: PWideChar;
                         var aUtf16Count: Integer;
                         var aUtf8: PUtf8Char;
                         var aUtf8Count: Integer);
  type
    TState = (ExpectingCharOrHiSurrogate, ExpectingLoSurrogate);
  var
    state: TState;
    ch: WideChar;
    hi: WideChar;
    code: CodePoint;
  begin
    hi    := #$0000;
    state := ExpectingCharOrHiSurrogate;

    while (aUtf16Count > 0) and (aUtf8Count > 0) do
    begin
      ch := WideChar(((Word(aUtf16^) and $ff00) shr 8) or ((Word(aUtf16^) and $ff) shl 8));

      case state of
        ExpectingCharOrHiSurrogate  : begin
                                       if Unicode.IsHiSurrogate(ch) then
                                       begin
                                         hi    := ch;
                                         state := ExpectingLoSurrogate;
                                       end
//                                     else if StrictEncoding and Unicode.IsLoSurrogate(aUtf16^) then
//                                       raise EInvalidEncoding.Create('Orphan Low Surrogate');
                                       else
                                         Unicode.CodepointToUtf8(Codepoint(ch), aUtf8, aUtf8Count);

                                       Inc(aUtf16);
                                       Dec(aUtf16Count);
                                     end;

        ExpectingLoSurrogate        : if Unicode.IsLoSurrogate(ch) then
                                      begin
                                        code := Unicode.SurrogatesToCodepoint(hi, ch);
                                        Unicode.CodepointToUtf8(code, aUtf8, aUtf8Count);

                                        Inc(aUtf16);
                                        Dec(aUtf16Count);

                                        state := ExpectingCharOrHiSurrogate;
                                      end;
//                                    else if StrictEncoding then
//                                      raise EInvalidEncoding.Create('Orphan High Surrogate');
      end;
    end;
  end;


  procedure _Utf16LeToUtf8(var aUtf16: PWideChar;
                           var aUtf16Count: Integer;
                           var aUtf8: PUtf8Char;
                           var aUtf8Count: Integer);
  type
    TState = (ExpectingCharOrHiSurrogate, ExpectingLoSurrogate);
  var
    state: TState;
    hi: WideChar;
    code: CodePoint;
  begin
    hi    := #$0000;
    state := ExpectingCharOrHiSurrogate;

    while (aUtf16Count > 0) and (aUtf8Count > 0) do
    begin
      case state of
        ExpectingCharOrHiSurrogate  : begin
                                       if Unicode.IsHiSurrogate(aUtf16^) then
                                       begin
                                         hi    := aUtf16^;
                                         state := ExpectingLoSurrogate;
                                       end
//                                     else if StrictEncoding and Unicode.IsLoSurrogate(aUtf16^) then
//                                       raise EInvalidEncoding.Create('Orphan Low Surrogate');
                                       else
                                         Unicode.CodepointToUtf8(Codepoint(aUtf16^), aUtf8, aUtf8Count);

                                       Inc(aUtf16);
                                       Dec(aUtf16Count);
                                     end;

        ExpectingLoSurrogate        : if Unicode.IsLoSurrogate(aUtf16^) then
                                      begin
                                        code := Unicode.SurrogatesToCodepoint(hi, aUtf16^);
                                        Unicode.CodepointToUtf8(code, aUtf8, aUtf8Count);

                                        Inc(aUtf16);
                                        Dec(aUtf16Count);

                                        state := ExpectingCharOrHiSurrogate;
                                      end;
//                                    else if StrictEncoding then
//                                      raise EInvalidEncoding.Create('Orphan High Surrogate');
      end;
    end;
  end;



end.
