
{$i deltics.unicode.inc}


  unit Deltics.Unicode.Exceptions;


interface

  uses
    Classes,
    SysUtils,
    Deltics.Unicode.BOM,
    Deltics.Unicode.Types;


  type
    EUnicode = class(Exception)
    public
      constructor Create(const aMessage: String; const aArgs: array of const); overload;
    end;

    EUnicodeDataloss          = class(EUnicode);
    EUnicodeRequiresMultibyte = class(EUnicode);
    EUnicodeOrphanSurrogate   = class(EUnicode);
    EInvalidCodepoint         = class(EUnicode);

    EInvalidSurrogate         = class(EUnicode);
      EInvalidHiSurrogate       = class(EInvalidSurrogate);
      EInvalidLoSurrogate       = class(EInvalidSurrogate);

    EInvalidEncoding    = class(EUnicode);    // An operation expecting a specific encoding encountered an incorrect encoding
    EMoreData           = class(EUnicode);    // Data was provided but the requested operation needs more data
    ENoData             = class(EUnicode);    // Data was expected/required but none was provided


implementation




{ EUnicode }

  constructor EUnicode.Create(const aMessage: String;
                              const aArgs: array of const);
  begin
    inherited CreateFmt(aMessage, aArgs);
  end;



end.
