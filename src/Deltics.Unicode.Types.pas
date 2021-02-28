
{$i deltics.unicode.inc}

  unit Deltics.Unicode.Types;


interface

  type
  {$ifdef UNICODE}
    Utf8String    = System.Utf8String;
    UnicodeString = System.UnicodeString;
  {$else}
    Utf8String    = type AnsiString;
    UnicodeString = type WideString;
  {$endif}

    Utf8Char      = type AnsiChar;
    PUtf8Char     = ^Utf8Char;

    AsciiString   = type Utf8String;
    AsciiChar     = type Utf8Char;

  // A Codepoint is a natively expressed (LE on Windows) 32-bit value
  //  identifying a unique Unicode codepoint and is an alias for the Utf32Char type.

    Codepoint   = Cardinal;
    PCodepoint  = ^Codepoint;


  // Dynamic arrays of Character types

    Utf8Array       = array of Utf8Char;
    WideCharArray   = array of WideChar;
    CodepointArray  = array of Codepoint;

  // Dynamic arrays of String types

    AnsiStringArray     = array of AnsiString;
    AsciiStringArray    = array of AsciiString;
    UnicodeStringArray  = array of UnicodeString;
    Utf8StringArray     = array of Utf8String;
    WideStringArray     = array of WideString;

  // Character/Codepoint Escape Encoders

    UnicodeEscapeBase = class
    public
      class function EscapedLength(const aChar: WideChar): Integer; overload; virtual; abstract;
      class function EscapedLength(const aCodepoint: Codepoint): Integer; overload; virtual; abstract;
      class procedure EscapeA(const aChar: WideChar; const aBuffer: PAnsiChar); overload; virtual; abstract;
      class procedure EscapeA(const aCodepoint: Codepoint; const aBuffer: PAnsiChar); overload; virtual; abstract;
      class procedure EscapeW(const aChar: WideChar; const aBuffer: PWideChar); overload; virtual; abstract;
      class procedure EscapeW(const aCodepoint: Codepoint; const aBuffer: PWideChar); overload; virtual; abstract;
    end;
    UnicodeEscape = class of UnicodeEscapeBase;


implementation



end.
