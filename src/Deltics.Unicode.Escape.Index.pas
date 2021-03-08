
{$i deltics.unicode.inc}

  unit Deltics.Unicode.Escape.Index;


interface

  uses
    Deltics.Unicode.Types;


  type
    UnicodeIndex = class (UnicodeEscapeBase)
      class function EscapedLength(const aChar: WideChar): Integer; override;
      class function EscapedLength(const aCodepoint: Codepoint): Integer; override;
      class procedure EscapeA(const aChar: WideChar; const aBuffer: PAnsiChar); override;
      class procedure EscapeA(const aCodepoint: Codepoint; const aBuffer: PAnsiChar); override;
      class procedure EscapeW(const aChar: WideChar; const aBuffer: PWideChar); override;
      class procedure EscapeW(const aCodepoint: Codepoint; const aBuffer: PWideChar); override;
    end;


implementation

  uses
    Deltics.Unicode.Utils;


{ UnicodeIndex }

  class function UnicodeIndex.EscapedLength(const aChar: WideChar): Integer;
  begin
    result := 6;
  end;


  class function UnicodeIndex.EscapedLength(const aCodepoint: Codepoint): Integer;
  {
    We do NOT raise an EInvalidCodepoint exception for codepoints outside the valid
     range since this escape is used by other escapes to report such invalid codepoints.

    i.e. although such codepoints are invalid, we can still escape that invalid codepoint
          using the normal codepoint index escape which is a naive hex representation of
          the codepoint (essentially UTF-32).

         This is not possible in other escapes. e.g. in a Json escape, any codepoint
          above $10000 must be escaped as a surrogate pair, but there is no way to encode
          codepoints above $10ffff as surrogates.
  }
  begin
    case aCodepoint of
      $00000000..$0000ffff  : result := 6;
      $00010000..$000fffff  : result := 7;
      $00100000..$00ffffff  : result := 8;
      $01000000..$0fffffff  : result := 9;
    else // $10000000..$ffffffff
      result := 10;
    end;
  end;


  class procedure UnicodeIndex.EscapeA(const aChar: WideChar; const aBuffer: PAnsiChar);
  begin
    SetBuffer(aBuffer, 'U+' + AnsiHex(Word(aChar), 4, TRUE));
  end;


  class procedure UnicodeIndex.EscapeA(const aCodepoint: Codepoint; const aBuffer: PAnsiChar);
  begin
    SetBuffer(aBuffer, 'U+' + AnsiHex(aCodepoint, EscapedLength(aCodepoint) - 2, TRUE));
  end;


  class procedure UnicodeIndex.EscapeW(const aChar: WideChar; const aBuffer: PWideChar);
  begin
    SetBuffer(aBuffer, 'U+' + WideHex(Word(aChar), 4, TRUE));
  end;


  class procedure UnicodeIndex.EscapeW(const aCodepoint: Codepoint; const aBuffer: PWideChar);
  begin
    SetBuffer(aBuffer, 'U+' + WideHex(aCodepoint, EscapedLength(aCodepoint) - 2, TRUE));
  end;



end.
