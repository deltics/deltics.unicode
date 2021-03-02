
{$i deltics.unicode.inc}

  unit Deltics.Unicode.Types;


interface

  uses
    Deltics.Strings.Types;

  {$i deltics.strings.types.aliases.inc}


  type
  // Base class for escape classes
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
