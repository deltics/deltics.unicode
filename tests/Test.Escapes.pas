
  unit Test.Escapes;


interface

  uses
    Deltics.Smoketest;


  type
    Escapes = class(TTest)
      procedure UtilsAnsiHex;
      procedure UtilsWideHex;
      procedure Index;
      procedure Json;
    end;



implementation

  uses
    Deltics.Unicode,
    Deltics.Unicode.Utils;


{ Escapes ---------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Escapes.UtilsAnsiHex;
  begin
    Test('AnsiHex(#$004a)').Assert(AnsiHex($004a, 4, TRUE)).Equals('004A');
    Test('AnsiHex(#$804a)').Assert(AnsiHex($804a, 4, FALSE)).Equals('804a');
    Test('AnsiHex($10000)').Assert(AnsiHex($10000, 5, FALSE)).Equals('10000');
    Test('AnsiHex($100000)').Assert(AnsiHex($100000, 6, FALSE)).Equals('100000');
    Test('AnsiHex($1000000)').Assert(AnsiHex($1000000, 7, FALSE)).Equals('1000000');
    Test('AnsiHex($10000000)').Assert(AnsiHex($10000000, 8, FALSE)).Equals('10000000');
    Test('AnsiHex($faedb4c7)').Assert(AnsiHex($faedb4c7, 8, FALSE)).Equals('faedb4c7');
    Test('AnsiHex($faedb4c7)').Assert(AnsiHex($faedb4c7, 8, TRUE)).Equals('FAEDB4C7');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Escapes.UtilsWideHex;
  begin
    Test('WideHex(#$004a)').Assert(WideHex($004a, 4, TRUE)).Equals('004A');
    Test('WideHex(#$804a)').Assert(WideHex($804a, 4, FALSE)).Equals('804a');
    Test('WideHex($10000)').Assert(WideHex($10000, 5, FALSE)).Equals('10000');
    Test('WideHex($100000)').Assert(WideHex($100000, 6, FALSE)).Equals('100000');
    Test('WideHex($1000000)').Assert(WideHex($1000000, 7, FALSE)).Equals('1000000');
    Test('WideHex($10000000)').Assert(WideHex($10000000, 8, FALSE)).Equals('10000000');
    Test('WideHex($faedb4c7)').Assert(WideHex($faedb4c7, 8, FALSE)).Equals('faedb4c7');
    Test('WideHex($faedb4c7)').Assert(WideHex($faedb4c7, 8, TRUE)).Equals('FAEDB4C7');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Escapes.Index;
  begin
    Test('Index(#$0041)').Assert(Unicode.Escape(WideChar(#$0041), UnicodeIndex)).Equals('U+0041');
    Test('Index(#$dc00)').Assert(Unicode.Escape(#$dc00, UnicodeIndex)).Equals('U+DC00');

    Test('Index($10000)').Assert(Unicode.Escape($10000, UnicodeIndex)).Equals('U+10000');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Escapes.Json;
  begin
    Test('Json(#$004a)').Assert(Unicode.Escape(WideChar(#$004a), JsonEscape)).Equals('\u004a');
    Test('Json(#$804a)').Assert(Unicode.Escape(#$804a, JsonEscape)).Equals('\u804a');
    Test('Json($10000)').Assert(Unicode.Escape($10000, JsonEscape)).Equals('\ud800\udc00');
    Test('Json($100000)').Assert(Unicode.Escape($100000, JsonEscape)).Equals('\udbc0\udc00');
  end;




end.
