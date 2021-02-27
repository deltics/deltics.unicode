
{$i deltics.unicode.inc}

  unit Deltics.Unicode.Class_;


interface

  uses
    Deltics.Unicode.Types;


  type
    Unicode = class
    public
      class procedure CodepointToSurrogates(const aCodepoint: Codepoint; var aHiSurrogate, aLoSurrogate: WideChar);
      class procedure CodepointToUtf8(const aCodepoint: Codepoint; var aUtf8Array: Utf8Array); overload;
      class procedure CodepointToUtf8(const aCodepoint: Codepoint; var aUtf8: PUtf8Char; var aMaxChars: Integer); overload;
      class function Index(const aChar: WideChar): String; overload;
      class function Index(const aCodepoint: Codepoint): String; overload;
      class function IsHiSurrogate(const aChar: WideChar): Boolean;
      class function IsLoSurrogate(const aChar: WideChar): Boolean;
      class function Json(const aChar: WideChar): String; overload;
      class function Json(const aCodepoint: Codepoint): String; overload;
      class function SurrogatesToCodepoint(const aHiSurrogate, aLoSurrogate: WideChar): Codepoint;
      class function Utf8Array(const aChars: array of Utf8Char): Utf8Array;
      class function Utf8ToCodepoint(const aUtf8: Utf8Array): Codepoint; overload;
      class function Utf8ToCodepoint(var aUtf8: PUtf8Char; var aUtf8Count: Integer): Codepoint; overload;
      class function Utf8ToUtf16(const aString: Utf8String): UnicodeString; overload;
      class procedure Utf8ToUtf16(var aUtf8: PUtf8Char; var aUtf8Count: Integer; var aUtf16: PWideChar; var aUtf16Count: Integer); overload;
      class function Utf16ToUtf8(const aString: UnicodeString): Utf8String; overload;
      class procedure Utf16ToUtf8(var aUtf16: PWideChar; var aUtf16Count: Integer; var aUtf8: PUtf8Char; var aUtf8Count: Integer); overload;

      class function Escape(const aChar: WideChar; const aEncoder: UnicodeEscape): String; overload;
      class function Escape(const aCodePoint: Codepoint; const aEncoder: UnicodeEscape): String; overload;
      class function EscapeA(const aChar: WideChar; const aEncoder: UnicodeEscape): AnsiString; overload;
      class function EscapeA(const aCodePoint: Codepoint; const aEncoder: UnicodeEscape): AnsiString; overload;
      class function EscapeUtf8(const aChar: WideChar; const aEncoder: UnicodeEscape): Utf8String; overload;
      class function EscapeUtf8(const aCodePoint: Codepoint; const aEncoder: UnicodeEscape): Utf8String; overload;
      class function EscapeW(const aChar: WideChar; const aEncoder: UnicodeEscape): UnicodeString; overload;
      class function EscapeW(const aCodePoint: Codepoint; const aEncoder: UnicodeEscape): UnicodeString; overload;
    end;


    function ToBin(aChar: Codepoint): String; overload;
    function ToBin(aChar: Utf8Char): String; overload;



implementation

  uses
    SysUtils,
    Windows,
    Deltics.Unicode.Escape.Index,
    Deltics.Unicode.Escape.Json,
    Deltics.Unicode.Exceptions,
    Deltics.Unicode.Transcode.CodepointToUtf8,
    Deltics.Unicode.Transcode.Utf8ToCodepoint,
    Deltics.Unicode.Transcode.Utf8ToUtf16,
    Deltics.Unicode.Transcode.Utf16ToUtf8;


  const
    MAX_Codepoint = $0010ffff;

    MIN_HiSurrogate : WideChar = #$d800;
    MAX_HiSurrogate : WideChar = #$dbff;
    MIN_LoSurrogate : WideChar = #$dc00;
    MAX_LoSurrogate : WideChar = #$dfff;

    MIN_Supplemental  = $10000;
    MIN_Surrogate     = $d800;
    MAX_Surrogate     = $dfff;


  type
    TByteArray = array of Byte;


  function ToBin(aChar: Codepoint): String;
  const
    BIT_CHAR: array[FALSE..TRUE] of Char = ('0', '1');
  var
    i: Integer;
    mask: Codepoint;
  begin
    mask := $80000000;
    SetLength(result, 32);

    for i := 1 to 32 do
    begin
      result[i] := BIT_CHAR[(aChar and mask) = mask];

      mask := mask shr 1;
    end;
  end;


  function ToBin(aChar: Utf8Char): String;
  const
    BIT_CHAR: array[FALSE..TRUE] of Char = ('0', '1');
  var
    i: Integer;
    mask: Codepoint;
  begin
    mask := $80;
    SetLength(result, 8);

    for i := 1 to 8 do
    begin
      result[i] := BIT_CHAR[(Byte(aChar) and mask) = mask];

      mask := mask shr 1;
    end;
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Unicode.CodepointToSurrogates(const aCodepoint: Codepoint;
                                                var   aHiSurrogate: WideChar;
                                                var   aLoSurrogate: WideChar);
  var
    codepoint: Deltics.Unicode.Types.Codepoint;
  begin
    if (aCodepoint > MAX_Codepoint) then
      raise EInvalidCodepoint.Create(aCodepoint);

    if ((aCodepoint >= MIN_Surrogate) and (aCodepoint <= MAX_Surrogate)) then
      raise EInvalidCodepoint.Create('The codepoint %s is reserved for surrogate encoding', [Index(aCodepoint)]);

    if (aCodepoint < MIN_Supplemental) then
      raise EInvalidCodepoint.Create('The codepoint %s is not in the Supplementary Plane', [Index(aCodepoint)]);

    codepoint := aCodepoint - $10000;

    aHiSurrogate := WideChar($d800 or ((codepoint shr 10) and $03ff));
    aLoSurrogate := WideChar($dc00 or (codepoint and $03ff));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Unicode.CodepointToUtf8(const aCodepoint: Codepoint;
                                          var   aUtf8: PUtf8Char;
                                          var   aMaxChars: Integer);
  begin
    _CodepointToUtf8(aCodepoint, aUtf8, aMaxChars);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Unicode.CodepointToUtf8(const aCodepoint: Codepoint;
                                          var   aUtf8Array: Utf8Array);
  var
    ptr: PUtf8Char;
    len: Integer;
  begin
    SetLength(aUtf8Array, 4);

    ptr := @aUtf8Array[0];
    len := 4;

    _CodepointToUtf8(aCodepoint, ptr, len);

    SetLength(aUtf8Array, 4 - len);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Escape(const aChar: WideChar; const aEncoder: UnicodeEscape): String;
  begin
    SetLength(result, aEncoder.EscapedLength(aChar));
  {$ifdef UNICODE}
    aEncoder.EscapeW(aChar, PWideChar(result));
  {$else}
    aEncoder.EscapeA(aChar, PAnsiChar(result));
  {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Escape(const aCodePoint: Codepoint; const aEncoder: UnicodeEscape): String;
  begin
    SetLength(result, aEncoder.EscapedLength(aCodepoint));
  {$ifdef UNICODE}
    aEncoder.EscapeW(aCodepoint, PWideChar(result));
  {$else}
    aEncoder.EscapeA(aCodepoint, PAnsiChar(result));
  {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.EscapeA(const aChar: WideChar; const aEncoder: UnicodeEscape): AnsiString;
  begin
    SetLength(result, aEncoder.EscapedLength(aChar));
    aEncoder.EscapeA(aChar, PAnsiChar(result));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.EscapeA(const aCodePoint: Codepoint; const aEncoder: UnicodeEscape): AnsiString;
  begin
    SetLength(result, aEncoder.EscapedLength(aCodepoint));
    aEncoder.EscapeA(aCodepoint, PAnsiChar(result));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.EscapeUtf8(const aChar: WideChar; const aEncoder: UnicodeEscape): Utf8String;
  begin
    SetLength(result, aEncoder.EscapedLength(aChar));
    aEncoder.EscapeA(aChar, PAnsiChar(result));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.EscapeUtf8(const aCodePoint: Codepoint; const aEncoder: UnicodeEscape): Utf8String;
  begin
    SetLength(result, aEncoder.EscapedLength(aCodepoint));
    aEncoder.EscapeA(aCodepoint, PAnsiChar(result));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.EscapeW(const aChar: WideChar; const aEncoder: UnicodeEscape): UnicodeString;
  begin
    SetLength(result, aEncoder.EscapedLength(aChar));
    aEncoder.EscapeW(aChar, PWideChar(result));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.EscapeW(const aCodePoint: Codepoint; const aEncoder: UnicodeEscape): UnicodeString;
  begin
    SetLength(result, aEncoder.EscapedLength(aCodepoint));
    aEncoder.EscapeW(aCodepoint, PWideChar(result));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Index(const aChar: WideChar): String;
  begin
    result := Escape(aChar, UnicodeIndex);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Index(const aCodepoint: Codepoint): String;
  begin
    result := Escape(aCodepoint, UnicodeIndex);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.IsHiSurrogate(const aChar: WideChar): Boolean;
  begin
    result := (aChar >= MIN_HiSurrogate) and (aChar <= MAX_HiSurrogate);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.IsLoSurrogate(const aChar: WideChar): Boolean;
  begin
    result := (aChar >= MIN_LoSurrogate) and (aChar <= MAX_LoSurrogate);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Json(const aChar: WideChar): String;
  begin
    result := Escape(aChar, JsonEscape);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Json(const aCodepoint: Codepoint): String;
  begin
    result := Escape(aCodepoint, JsonEscape);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.SurrogatesToCodepoint(const aHiSurrogate: WideChar;
                                               const aLoSurrogate: WideChar): Codepoint;
  begin
    if NOT IsHiSurrogate(aHiSurrogate) then
      raise EInvalidHiSurrogate.Create('%s is not a valid high surrogate character', [Index(aHiSurrogate)]);

    if NOT IsLoSurrogate(aLoSurrogate) then
      raise EInvalidLoSurrogate.Create('%s is not a valid low surrogate character', [Index(aLoSurrogate)]);

    result := ((Word(aHiSurrogate) - $d800) shl 10)
            + (Word(aLoSurrogate) - $dc00)
            + $10000;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Utf8Array(const aChars: array of Utf8Char): Utf8Array;
  begin
    SetLength(result, Length(aChars));
    CopyMemory(@result[0], @aChars[0], Length(aChars));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Utf8ToCodepoint(const aUtf8: Utf8Array): Codepoint;
  var
    ptr: PUtf8Char;
    count: Integer;
  begin
    ptr   := @aUtf8[0];
    count := Length(aUtf8);

    result := _Utf8ToCodepoint(ptr, count);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Utf8ToCodepoint(var aUtf8: PUtf8Char;
                                         var aUtf8Count: Integer): Codepoint;
  begin
    result := _Utf8ToCodepoint(aUtf8, aUtf8Count);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Utf8ToUtf16(const aString: Utf8String): UnicodeString;
  var
    utf8: PUtf8Char;
    utf8len: Integer;
    utf16: PWideChar;
    utf16len: Integer;
  begin
    utf8len  := Length(aString);
    utf16len := utf8len;

    SetLength(result, utf16len);

    utf8  := PUtf8Char(aString);
    utf16 := PWideChar(result);

    _Utf8ToUtf16(utf8, utf8len, utf16, utf16len);

    SetLength(result, Length(result) - utf16len);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Unicode.Utf8ToUtf16(var aUtf8: PUtf8Char;
                                      var aUtf8Count: Integer;
                                      var aUtf16: PWideChar;
                                      var aUtf16Count: Integer);
  begin
    _Utf8ToUtf16(aUtf8, aUtf8Count, aUtf16, aUtf16Count);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Utf16ToUtf8(const aString: UnicodeString): Utf8String;
  var
    utf8: PUtf8Char;
    utf8len: Integer;
    utf16: PWideChar;
    utf16len: Integer;
  begin
    utf16len  := Length(aString);
    utf8len   := utf16len * 3;

    SetLength(result, utf8len);

    utf16 := PWideChar(aString);
    utf8  := PUtf8Char(result);

    _Utf16ToUtf8(utf16, utf16len, utf8, utf8len);

    SetLength(result, Length(result) - utf8len);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Unicode.Utf16ToUtf8(var aUtf16: PWideChar;
                                      var aUtf16Count: Integer;
                                      var aUtf8: PUtf8Char;
                                      var aUtf8Count: Integer);
  begin
    _Utf16ToUtf8(aUtf16, aUtf16Count, aUtf8, aUtf8Count);
  end;








end.
