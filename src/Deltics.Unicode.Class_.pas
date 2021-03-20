
{$i deltics.unicode.inc}

  unit Deltics.Unicode.Class_;


interface

  uses
    Deltics.Unicode.Types;


  type
    Unicode = class
    public
      class function AnsiCharToWide(const aChar: AnsiChar): WideChar;
      class procedure CodepointToSurrogates(const aCodepoint: Codepoint; var aHiSurrogate, aLoSurrogate: WideChar);
      class procedure CodepointToUtf8(const aCodepoint: Codepoint; var aUtf8Array: Utf8Array); overload;
      class procedure CodepointToUtf8(const aCodepoint: Codepoint; var aUtf8: PUtf8Char; var aMaxChars: Integer); overload;
      class function IsHiSurrogate(const aChar: WideChar): Boolean;
      class function IsLoSurrogate(const aChar: WideChar): Boolean;
      class function Json(const aChar: WideChar): Utf8String; overload;
      class function Json(const aCodepoint: Codepoint): Utf8String; overload;
      class function Ref(const aChar: WideChar): String; overload;
      class function Ref(const aCodepoint: Codepoint): String; overload;
      class function SurrogatesToCodepoint(const aHiSurrogate, aLoSurrogate: WideChar): Codepoint;
      class function Utf8Array(const aChars: array of Utf8Char): Utf8Array;
      class function Utf8ToCodepoint(const aUtf8: Utf8Array): Codepoint; overload;
      class function Utf8ToCodepoint(var aUtf8: PUtf8Char; var aUtf8Count: Integer): Codepoint; overload;
      class function Utf8ToUtf16(const aString: Utf8String): UnicodeString; overload;
      class procedure Utf8ToUtf16(var aUtf8: PUtf8Char; var aUtf8Count: Integer; var aUtf16: PWideChar; var aUtf16Count: Integer); overload;
      class function Utf16ToUtf8(const aString: UnicodeString): Utf8String; overload;
      class procedure Utf16ToUtf8(var aUtf16: PWideChar; var aUtf16Count: Integer; var aUtf8: PUtf8Char; var aUtf8Count: Integer); overload;
      class procedure Utf16BeToUtf8(var aUtf16: PWideChar; var aUtf16Count: Integer; var aUtf8: PUtf8Char; var aUtf8Count: Integer);
      class function WideCharToAnsi(const aChar: WideChar): AnsiChar;

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

  const
    MAP_AnsiToWide : array[AnsiChar] of WideChar = (
            #$0000, #$0001, #$0002, #$0003, #$0004, #$0005, #$0006, #$0007, #$0008, #$0009,
            #$000A, #$000B, #$000C, #$000D, #$000E, #$000F, #$0010, #$0011, #$0012, #$0013,
            #$0014, #$0015, #$0016, #$0017, #$0018, #$0019, #$001A, #$001B, #$001C, #$001D,
            #$001E, #$001F, #$0020, #$0021, #$0022, #$0023, #$0024, #$0025, #$0026, #$0027,
            #$0028, #$0029, #$002A, #$002B, #$002C, #$002D, #$002E, #$002F, #$0030, #$0031,
            #$0032, #$0033, #$0034, #$0035, #$0036, #$0037, #$0038, #$0039, #$003A, #$003B,
            #$003C, #$003D, #$003E, #$003F, #$0040, #$0041, #$0042, #$0043, #$0044, #$0045,
            #$0046, #$0047, #$0048, #$0049, #$004A, #$004B, #$004C, #$004D, #$004E, #$004F,
            #$0050, #$0051, #$0052, #$0053, #$0054, #$0055, #$0056, #$0057, #$0058, #$0059,
            #$005A, #$005B, #$005C, #$005D, #$005E, #$005F, #$0060, #$0061, #$0062, #$0063,
            #$0064, #$0065, #$0066, #$0067, #$0068, #$0069, #$006A, #$006B, #$006C, #$006D,
            #$006E, #$006F, #$0070, #$0071, #$0072, #$0073, #$0074, #$0075, #$0076, #$0077,
            #$0078, #$0079, #$007A, #$007B, #$007C, #$007D, #$007E, #$007F,

            #$20AC, #$0081, #$201A, #$0192, #$201E, #$2026, #$2020, #$2021, #$02C6, #$2030,
            #$0160, #$2039, #$0152, #$008D, #$017D, #$008F, #$0090, #$2018, #$2019, #$201C,
            #$201D, #$2022, #$2013, #$2014, #$02DC, #$2122, #$0161, #$203A, #$0153, #$009D,
            #$017E, #$0178, #$00A0, #$00A1, #$00A2, #$00A3, #$00A4, #$00A5, #$00A6, #$00A7,
            #$00A8, #$00A9, #$00AA, #$00AB, #$00AC, #$00AD, #$00AE, #$00AF, #$00B0, #$00B1,
            #$00B2, #$00B3, #$00B4, #$00B5, #$00B6, #$00B7, #$00B8, #$00B9, #$00BA, #$00BB,
            #$00BC, #$00BD, #$00BE, #$00BF, #$00C0, #$00C1, #$00C2, #$00C3, #$00C4, #$00C5,
            #$00C6, #$00C7, #$00C8, #$00C9, #$00CA, #$00CB, #$00CC, #$00CD, #$00CE, #$00CF,
            #$00D0, #$00D1, #$00D2, #$00D3, #$00D4, #$00D5, #$00D6, #$00D7, #$00D8, #$00D9,
            #$00DA, #$00DB, #$00DC, #$00DD, #$00DE, #$00DF, #$00E0, #$00E1, #$00E2, #$00E3,
            #$00E4, #$00E5, #$00E6, #$00E7, #$00E8, #$00E9, #$00EA, #$00EB, #$00EC, #$00ED,
            #$00EE, #$00EF, #$00F0, #$00F1, #$00F2, #$00F3, #$00F4, #$00F5, #$00F6, #$00F7,
            #$00F8, #$00F9, #$00FA, #$00FB, #$00FC, #$00FD, #$00FE, #$00FF);


  type
    TByteArray = array of Byte;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
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


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
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
  class function Unicode.AnsiCharToWide(const aChar: AnsiChar): WideChar;
  begin
    result := MAP_AnsiToWide[aChar];
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
      raise EInvalidCodepoint.Create('The codepoint %s is reserved for surrogate encoding', [Ref(aCodepoint)]);

    if (aCodepoint < MIN_Supplemental) then
      raise EInvalidCodepoint.Create('The codepoint %s is not in the Supplementary Plane', [Ref(aCodepoint)]);

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
  class function Unicode.Json(const aChar: WideChar): Utf8String;
  begin
    result := EscapeUtf8(aChar, JsonEscape);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Json(const aCodepoint: Codepoint): Utf8String;
  begin
    result := Escapeutf8(aCodepoint, JsonEscape);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Ref(const aChar: WideChar): String;
  begin
    result := Escape(aChar, UnicodeIndex);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.Ref(const aCodepoint: Codepoint): String;
  begin
    result := Escape(aCodepoint, UnicodeIndex);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.SurrogatesToCodepoint(const aHiSurrogate: WideChar;
                                               const aLoSurrogate: WideChar): Codepoint;
  begin
    if NOT IsHiSurrogate(aHiSurrogate) then
      raise EInvalidHiSurrogate.Create('%s is not a valid high surrogate character', [Ref(aHiSurrogate)]);

    if NOT IsLoSurrogate(aLoSurrogate) then
      raise EInvalidLoSurrogate.Create('%s is not a valid low surrogate character', [Ref(aLoSurrogate)]);

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

    _Utf8ToUtf16Le(utf8, utf8len, utf16, utf16len);

    SetLength(result, Length(result) - utf16len);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Unicode.Utf8ToUtf16(var aUtf8: PUtf8Char;
                                      var aUtf8Count: Integer;
                                      var aUtf16: PWideChar;
                                      var aUtf16Count: Integer);
  begin
    _Utf8ToUtf16Le(aUtf8, aUtf8Count, aUtf16, aUtf16Count);
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

    _Utf16LeToUtf8(utf16, utf16len, utf8, utf8len);

    SetLength(result, Length(result) - utf8len);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Unicode.Utf16ToUtf8(var aUtf16: PWideChar;
                                      var aUtf16Count: Integer;
                                      var aUtf8: PUtf8Char;
                                      var aUtf8Count: Integer);
  begin
    _Utf16LeToUtf8(aUtf16, aUtf16Count, aUtf8, aUtf8Count);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure Unicode.Utf16BeToUtf8(var aUtf16: PWideChar;
                                        var aUtf16Count: Integer;
                                        var aUtf8: PUtf8Char;
                                        var aUtf8Count: Integer);
  begin
    _Utf16BeToUtf8(aUtf16, aUtf16Count, aUtf8, aUtf8Count);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Unicode.WideCharToAnsi(const aChar: WideChar): AnsiChar;
  begin
    case aChar of
      #$0000..#$007f,
      #$0081,
      #$008d,
      #$008f,
      #$0090,
      #$009d,
      #$00a0..#$00ff  : begin
                          result := AnsiChar(aChar);
                          EXIT;
                        end;
    else
      for result := #$80 to #$9f do
        if aChar = MAP_AnsiToWide[result] then
          EXIT;
    end;

    raise EUnicode.Create('{char} does not map to a single-byte AnsiChar.  Use Ansi.FromWide(PWideChar) instead.', [Ref(aChar)]);
  end;






end.
