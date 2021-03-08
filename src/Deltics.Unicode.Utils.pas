{
  * X11 (MIT) LICENSE *

  Copyright © 2013 Jolyon Smith

  Permission is hereby granted, free of charge, to any person obtaining a copy of
   this software and associated documentation files (the "Software"), to deal in
   the Software without restriction, including without limitation the rights to
   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
   of the Software, and to permit persons to whom the Software is furnished to do
   so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.


  * GPL and Other Licenses *

  The FSF deem this license to be compatible with version 3 of the GPL.
   Compatability with other licenses should be verified by reference to those
   other license terms.


  * Contact Details *

  Original author : Jolyon Smith
  skype           : deltics
  e-mail          : <EXTLINK mailto: jsmith@deltics.co.nz>jsmith@deltics.co.nz</EXTLINK>
  website         : <EXTLINK http://www.deltics.co.nz>www.deltics.co.nz</EXTLINK>
}

{$i deltics.unicode.inc}

  unit Deltics.Unicode.Utils;


interface

  uses
    Deltics.Unicode.Types;


  function AnsiHex(const aValue: Cardinal; const aNumDigits: Integer; const aUppercase: Boolean): AnsiString;
  function WideHex(const aValue: Cardinal; const aNumDigits: Integer; const aUppercase: Boolean): UnicodeString;

  procedure SetBuffer(const aBuffer: PAnsiChar; const aString: AnsiString); overload;
  procedure SetBuffer(const aBuffer: PWideChar; const aString: UnicodeString); overload;



implementation

  uses
    Windows;


  function AnsiHex(const aValue: Cardinal; const aNumDigits: Integer; const aUppercase: Boolean): AnsiString;
  const
    DIGITS: array[FALSE..TRUE] of AnsiString = ('0123456789abcdef', '0123456789ABCDEF');
  var
    i: Integer;
    pBuf: PByte;
    pOut: PAnsiChar;
    shift: Boolean;
  begin
    SetLength(result, aNumDigits);

    pBuf := PByte(@aValue);
  {$ifdef 64BIT}
    pOut := PAnsiChar(Int64(result) + aNumDigits - 1);
  {$else}
    pOut := PAnsiChar(Integer(result) + aNumDigits - 1);
  {$endif}

    shift := FALSE;
    for i := aNumDigits downto 1 do
    begin
      if shift then
        pOut^ := DIGITS[aUppercase][(pBuf^ and $f0) shr 4 + 1]
      else
        pOut^ := DIGITS[aUppercase][(pBuf^ and $0f) + 1];

      Dec(pOut);
      shift := NOT shift;

      if NOT shift then
        Inc(pBuf);
    end;
  end;


  function WideHex(const aValue: Cardinal; const aNumDigits: Integer; const aUppercase: Boolean): UnicodeString;
  const
    DIGITS: array[FALSE..TRUE] of UnicodeString = ('0123456789abcdef', '0123456789ABCDEF');
  var
    i: Integer;
    pBuf: PByte;
    pOut: PWideChar;
    shift: Boolean;
  begin
    SetLength(result, aNumDigits);

    pBuf := PByte(@aValue);
  {$ifdef 64BIT}
    pOut := PWideChar(Int64(result) + (aNumDigits * 2) - 2);
  {$else}
    pOut := PWideChar(Integer(result) + (aNumDigits * 2) - 2);
  {$endif}

    shift := FALSE;
    for i := aNumDigits downto 1 do
    begin
      if shift then
        pOut^ := DIGITS[aUppercase][(pBuf^ and $f0) shr 4 + 1]
      else
        pOut^ := DIGITS[aUppercase][(pBuf^ and $0f) + 1];

      Dec(pOut);
      shift := NOT shift;

      if NOT shift then
        Inc(pBuf);
    end;
  end;


  procedure SetBuffer(const aBuffer: PAnsiChar; const aString: AnsiString);
  begin
    CopyMemory(Pointer(aBuffer), Pointer(aString), Length(aString));
  end;


  procedure SetBuffer(const aBuffer: PWideChar; const aString: UnicodeString);
  begin
    CopyMemory(Pointer(aBuffer), Pointer(aString), Length(aString) * 2);
  end;


end.
