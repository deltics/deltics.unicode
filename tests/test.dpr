
{$apptype CONSOLE}

  program test;

uses
  Deltics.Smoketest,
  Deltics.Unicode in '..\src\Deltics.Unicode.pas',
  Deltics.Unicode.Bom in '..\src\Deltics.Unicode.Bom.pas',
  Deltics.Unicode.Class_ in '..\src\Deltics.Unicode.Class_.pas',
  Deltics.Unicode.Exceptions in '..\src\Deltics.Unicode.Exceptions.pas',
  Deltics.Unicode.Transcode.CodepointToUtf8 in '..\src\Deltics.Unicode.Transcode.CodepointToUtf8.pas',
  Deltics.Unicode.Transcode.Utf8ToCodepoint in '..\src\Deltics.Unicode.Transcode.Utf8ToCodepoint.pas',
  Deltics.Unicode.Transcode.Utf8ToUtf16 in '..\src\Deltics.Unicode.Transcode.Utf8ToUtf16.pas',
  Deltics.Unicode.Transcode.Utf16ToUtf8 in '..\src\Deltics.Unicode.Transcode.Utf16ToUtf8.pas',
  Deltics.Unicode.Types in '..\src\Deltics.Unicode.Types.pas',
  Test.Unicode in 'Test.Unicode.pas',
  Test.Escapes in 'Test.Escapes.pas',
  Deltics.Unicode.Escape.Index in '..\src\Deltics.Unicode.Escape.Index.pas',
  Deltics.Unicode.Utils in '..\src\Deltics.Unicode.Utils.pas',
  Deltics.Unicode.Escape.Json in '..\src\Deltics.Unicode.Escape.Json.pas';

begin
  TestRun.Test(Escapes);
  TestRun.Test(Utils);
end.
