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

  unit Deltics.Unicode;


interface

  uses
    Classes,
    SysUtils,
    Deltics.Unicode.Bom,
    Deltics.Unicode.Class_,
    Deltics.Unicode.Escape.Index,
    Deltics.Unicode.Escape.Json,
    Deltics.Unicode.Exceptions,
    Deltics.Unicode.Types;


  type
  // Bom types
    TBom        = Deltics.Unicode.Bom.TBom;

    Utf8Bom     = Deltics.Unicode.Bom.Utf8Bom;
    Utf16Bom    = Deltics.Unicode.Bom.Utf16Bom;
    Utf16LEBom  = Deltics.Unicode.Bom.Utf16LEBom;
    Utf32Bom    = Deltics.Unicode.Bom.Utf32Bom;
    Utf32LEBom  = Deltics.Unicode.Bom.Utf32LEBom;

  // String types
    AsciiString       = Deltics.Unicode.Types.AsciiString;
    AsciiChar         = Deltics.Unicode.Types.AsciiChar;

    UnicodeString     = Deltics.Unicode.Types.UnicodeString;
    Utf8String        = Deltics.Unicode.Types.Utf8String;

  // Char types
    Utf8Char          = Deltics.Unicode.Types.Utf8Char;
    PUtf8Char         = Deltics.Unicode.Types.PUtf8Char;

    Codepoint         = Deltics.Unicode.Types.Codepoint;
    PCodepoint        = Deltics.Unicode.Types.PCodepoint;

  // Char array types
    Utf8Array       = Deltics.Unicode.Types.Utf8Array;
    WideCharArray   = Deltics.Unicode.Types.WideCharArray;
    CodepointArray  = Deltics.Unicode.Types.CodepointArray;

  // String array types
    AnsiStringArray     = Deltics.Unicode.Types.AnsiStringArray;
    AsciiStringArray    = Deltics.Unicode.Types.AsciiStringArray;
    UnicodeStringArray  = Deltics.Unicode.Types.UnicodeStringArray;
    Utf8StringArray     = Deltics.Unicode.Types.Utf8StringArray;
    WideStringArray     = Deltics.Unicode.Types.WideStringArray;

  // Escapes
    UnicodeIndex    = Deltics.Unicode.Escape.Index.UnicodeIndex;
    JsonEscape      = Deltics.Unicode.Escape.Json.JsonEscape;

  // Exceptions
    EUnicode                  = Deltics.Unicode.Exceptions.EUnicode;
    EUnicodeDataloss          = Deltics.Unicode.Exceptions.EUnicodeDataloss;
    EUnicodeRequiresMultibyte = Deltics.Unicode.Exceptions.EUnicodeRequiresMultibyte;
    EUnicodeOrphanSurrogate   = Deltics.Unicode.Exceptions.EUnicodeOrphanSurrogate;
    EInvalidCodepoint         = Deltics.Unicode.Exceptions.EInvalidCodepoint;
    EInvalidSurrogate         = Deltics.Unicode.Exceptions.EInvalidSurrogate;
    EInvalidHiSurrogate       = Deltics.Unicode.Exceptions.EInvalidHiSurrogate;
    EInvalidLoSurrogate       = Deltics.Unicode.Exceptions.EInvalidLoSurrogate;

    EInvalidEncoding          = Deltics.Unicode.Exceptions.EInvalidEncoding;
    EMoreData                 = Deltics.Unicode.Exceptions.EMoreData;
    ENoData                   = Deltics.Unicode.Exceptions.ENoData;


  const
    BytesPerChar  = {$ifdef UNICODE} 2 {$else} 1 {$endif};


  type
    Unicode   = Deltics.Unicode.Class_.Unicode;




implementation




end.
