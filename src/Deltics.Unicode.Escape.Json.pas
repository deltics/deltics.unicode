
{$i deltics.unicode.inc}

  unit Deltics.Unicode.Escape.Json;


interface

  uses
    Deltics.Unicode.Types;


  type
    JsonEscape = class (UnicodeEscapeBase)
      class function EscapedLength(const aChar: WideChar): Integer; override;
      class function EscapedLength(const aCodepoint: Codepoint): Integer; override;
      class procedure EscapeA(const aChar: WideChar; const aBuffer: PAnsiChar); override;
      class procedure EscapeA(const aCodepoint: Codepoint; const aBuffer: PAnsiChar); override;
      class procedure EscapeW(const aChar: WideChar; const aBuffer: PWideChar); override;
      class procedure EscapeW(const aCodepoint: Codepoint; const aBuffer: PWideChar); override;
    end;


implementation

  uses
    Deltics.Unicode,
    Deltics.Unicode.Exceptions,
    Deltics.Unicode.Utils;


{ JsonEscape }

  class function JsonEscape.EscapedLength(const aChar: WideChar): Integer;
  begin
    result := 6;
  end;


  class function JsonEscape.EscapedLength(const aCodepoint: Codepoint): Integer;
  begin
    case aCodepoint of
      $00000000..$0000ffff  : result := 6;
      $00010000..$0010ffff  : result := 12;
    else
      raise EInvalidCodepoint.Create(aCodepoint);
    end;
  end;


  class procedure JsonEscape.EscapeA(const aChar: WideChar; const aBuffer: PAnsiChar);
  begin
    SetBuffer(aBuffer, '\u' + AnsiHex(Word(aChar), 4, FALSE));
  end;


  class procedure JsonEscape.EscapeA(const aCodepoint: Codepoint; const aBuffer: PAnsiChar);
  var
    hi, lo: WideChar;
  begin
    case aCodepoint of
      $00000000..$0000ffff  : EscapeA(WideChar(aCodepoint), aBuffer);
      $00010000..$0010ffff  : begin
                                Unicode.CodepointToSurrogates(aCodepoint, hi, lo);
                                SetBuffer(aBuffer, '\u' + AnsiHex(Word(hi), 4, FALSE)
                                                 + '\u' + AnsiHex(Word(lo), 4, FALSE));
                              end;
    else
      raise EInvalidCodepoint.Create(aCodepoint);
    end;
  end;


  class procedure JsonEscape.EscapeW(const aChar: WideChar; const aBuffer: PWideChar);
  begin
    SetBuffer(aBuffer, '\u' + WideHex(Word(aChar), 4, FALSE));
  end;


  class procedure JsonEscape.EscapeW(const aCodepoint: Codepoint; const aBuffer: PWideChar);
  var
    hi, lo: WideChar;
  begin
    case aCodepoint of
      $00000000..$0000ffff  : EscapeW(WideChar(aCodepoint), aBuffer);
      $00010000..$0010ffff  : begin
                                Unicode.CodepointToSurrogates(aCodepoint, hi, lo);
                                SetBuffer(aBuffer, '\u' + WideHex(Word(hi), 4, FALSE)
                                                 + '\u' + WideHex(Word(lo), 4, FALSE));
                              end;
    else
      raise EInvalidCodepoint.Create(aCodepoint);
    end;
  end;



end.
