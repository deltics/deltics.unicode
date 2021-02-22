
  unit Test.Unicode;


interface

  uses
    Deltics.Smoketest;


  type
    Utils = class(TTest)
      procedure IsHiSurrogateReturnsFalseForNonHiSurrogates;
      procedure IsHiSurrogateReturnsTrueForHiSurrogates;
      procedure IsLoSurrogateReturnsFalseForNonLoSurrogates;
      procedure IsLoSurrogateReturnsTrueForLoSurrogates;
      procedure CodepointToSurrogateEncodesValidSurrogatesCorrectly;
      procedure CodepointToSurrogateRaisesEInvalidCodepointIfCodepointIsInvalid;
      procedure CodepointToSurrogateRaisesEInvalidCodepointIfCodepointLiesInBMP;
      procedure CodepointToSurrogateRaisesEInvalidCodepointIfCodepointIsReservedForSurrogates;
      procedure CodepointToUtf8EncodesValidCodepointsCorrectly;
      procedure SurrogatesToCodepointDecodesValidSurrogatesCorrectly;
      procedure SurrogatesToCodepointRaisesEInvalidHiSurrogateIfHiSurrogateIsNotValid;
      procedure SurrogatesToCodepointRaisesEInvalidLoSurrogateIfLoSurrogateIsNotValid;
      procedure Utf16ToUtf8StringsEncodesValidStringCorrectly;
      procedure Utf8ToCodepointEncodesValidUtf8Correctly;
      procedure Utf8ToCodepointRaisesEInvalidEncodingIfByteIsNotAValidLeadByte;
      procedure Utf8ToCodepointRaisesEInvalidEncodingIfContinuationByteIsInvalid;
      procedure Utf8ToCodepointRaisesEInvalidEncodingIfFirstOfTwoContinuationBytesIsInvalid;
      procedure Utf8ToCodepointRaisesEInvalidEncodingIfFirstOfThreeContinuationBytesIsInvalid;
      procedure Utf8ToCodepointRaisesEInvalidEncodingIfSecondOfTwoContinuationBytesIsInvalid;
      procedure Utf8ToCodepointRaisesEInvalidEncodingIfSecondOfThreeContinuationBytesIsInvalid;
      procedure Utf8ToCodepointRaisesEInvalidEncodingIfThirdOfThreeContinuationBytesIsInvalid;
      procedure Utf8ToCodepointRaisesEMoreDataIfOneRequiredContinuationByteOfOneIsNotAvailable;
      procedure Utf8ToCodepointRaisesEMoreDataIfAtLeastOneRequiredContinuationByteOfTwoIsNotAvailable;
      procedure Utf8ToCodepointRaisesEMoreDataIfAtLeastOneRequiredContinuationByteOfThreeIsNotAvailable;
      procedure Utf8ToCodepointRaisesENoData;
      procedure Utf8ToUtf16StringsEncodesValidStringCorrectly;
      procedure Utf8ToCodepointYieldsEmptyArrayIfInputArrayIsEmpty;
    end;



implementation

  uses
    Deltics.Unicode;


{ Transcoding ------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }




{ UnicodeUtils }

  procedure Utils.CodepointToSurrogateEncodesValidSurrogatesCorrectly;
  var
    hi, lo: WideChar;
  begin
    Unicode.CodepointToSurrogates($10000, hi, lo);
    Test('CodepointToSurrogates($10000).hi').Assert(hi).Equals(WideChar($d800));
    Test('CodepointToSurrogates($10000).lo').Assert(lo).Equals(WideChar($dc00));

    Unicode.CodepointToSurrogates($10437, hi, lo);
    Test('CodepointToSurrogates($10437).hi').Assert(hi).Equals(WideChar($d801));
    Test('CodepointToSurrogates($10437).lo').Assert(lo).Equals(WideChar($dc37));

    Unicode.CodepointToSurrogates($24b62, hi, lo);
    Test('CodepointToSurrogates($24b62).hi').Assert(hi).Equals(WideChar($d852));
    Test('CodepointToSurrogates($24b62).lo').Assert(lo).Equals(WideChar($df62));

    Unicode.CodepointToSurrogates($10ffff, hi, lo);
    Test('CodepointToSurrogates($10ffff).hi').Assert(hi).Equals(WideChar($dbff));
    Test('CodepointToSurrogates($10ffff).lo').Assert(lo).Equals(WideChar($dfff));
  end;


  procedure Utils.CodepointToSurrogateRaisesEInvalidCodepointIfCodepointIsInvalid;
  var
    hi, lo: WideChar;
  begin
    Test.Raises(EInvalidCodepoint, 'U+110000 is not a valid codepoint');
    Unicode.CodepointToSurrogates($110000, hi, lo);
  end;


  procedure Utils.CodepointToSurrogateRaisesEInvalidCodepointIfCodepointIsReservedForSurrogates;
  var
    hi, lo: WideChar;
  begin
    Test.Raises(EInvalidCodepoint, 'The codepoint U+D800 is reserved for surrogate encoding');
    Unicode.CodepointToSurrogates($d800, hi, lo);
  end;


  procedure Utils.CodepointToSurrogateRaisesEInvalidCodepointIfCodepointLiesInBMP;
  var
    hi, lo: WideChar;
  begin
    Test.Raises(EInvalidCodepoint, 'The codepoint U+00A9 is not in the Supplementary Plane');
    Unicode.CodepointToSurrogates($00a9, hi, lo);
  end;


  procedure Utils.CodepointToUtf8EncodesValidCodepointsCorrectly;
  var
    utf8: Utf8Array;
  begin
    Unicode.CodepointToUtf8($0041, utf8);
    if Test('CodepointToUtf8($0041).length').Assert(Length(utf8)).Equals(1).Passed then
      Test('CodepointToUtf8($0041)[0]').Assert(utf8[0]).Equals(#$41);

    Unicode.CodepointToUtf8($00a9, utf8);
    if Test('CodepointToUtf8($00a9).length').Assert(Length(utf8)).Equals(2).Passed then
    begin
      Test('CodepointToUtf8($00a9)[0]').Assert(utf8[0]).Equals(#$c2);
      Test('CodepointToUtf8($00a9)[1]').Assert(utf8[1]).Equals(#$a9);
    end;

    Unicode.CodepointToUtf8($d55c, utf8);
    if Test('CodepointToUtf8($d55c).length').Assert(Length(utf8)).Equals(3).Passed then
    begin
      Test('CodepointToUtf8($d55c)[0]').Assert(utf8[0]).Equals(#$ed);
      Test('CodepointToUtf8($d55c)[1]').Assert(utf8[1]).Equals(#$95);
      Test('CodepointToUtf8($d55c)[1]').Assert(utf8[2]).Equals(#$9c);
    end;

    Unicode.CodepointToUtf8($10348, utf8);
    if Test('CodepointToUtf8($10348).length').Assert(Length(utf8)).Equals(4).Passed then
    begin
      Test('CodepointToUtf8($10348)[0]').Assert(utf8[0]).Equals(#$f0);
      Test('CodepointToUtf8($10348)[1]').Assert(utf8[1]).Equals(#$90);
      Test('CodepointToUtf8($10348)[2]').Assert(utf8[2]).Equals(#$8d);
      Test('CodepointToUtf8($10348)[3]').Assert(utf8[3]).Equals(#$88);
    end;
  end;


  procedure Utils.IsHiSurrogateReturnsFalseForNonHiSurrogates;
  begin
    Test('IsHiSurrogate($0040)').Assert(Unicode.IsHiSurrogate(WideChar($0040))).IsFalse;
    Test('IsHiSurrogate($d799)').Assert(Unicode.IsHiSurrogate(WideChar($d799))).IsFalse;
    Test('IsHiSurrogate($dc00)').Assert(Unicode.IsHiSurrogate(WideChar($dc00))).IsFalse;
    Test('IsHiSurrogate($fffe)').Assert(Unicode.IsHiSurrogate(WideChar($fffe))).IsFalse;
  end;


  procedure Utils.IsHiSurrogateReturnsTrueForHiSurrogates;
  begin
    Test('IsHiSurrogate($d800)').Assert(Unicode.IsHiSurrogate(WideChar($d800))).IsTrue;
    Test('IsHiSurrogate($da00)').Assert(Unicode.IsHiSurrogate(WideChar($da00))).IsTrue;
    Test('IsHiSurrogate($dbff)').Assert(Unicode.IsHiSurrogate(WideChar($dbff))).IsTrue;
  end;


  procedure Utils.IsLoSurrogateReturnsFalseForNonLoSurrogates;
  begin
    Test('IsLoSurrogate($0040)').Assert(Unicode.IsLoSurrogate(WideChar($0040))).IsFalse;
    Test('IsLoSurrogate($dbff)').Assert(Unicode.IsLoSurrogate(WideChar($dbff))).IsFalse;
    Test('IsLoSurrogate($e000)').Assert(Unicode.IsLoSurrogate(WideChar($e000))).IsFalse;
    Test('IsLoSurrogate($fffe)').Assert(Unicode.IsLoSurrogate(WideChar($fffe))).IsFalse;
  end;


  procedure Utils.IsLoSurrogateReturnsTrueForLoSurrogates;
  begin
    Test('IsLoSurrogate($dc00)').Assert(Unicode.IsLoSurrogate(WideChar($dc00))).IsTrue;
    Test('IsLoSurrogate($dd72)').Assert(Unicode.IsLoSurrogate(WideChar($dd72))).IsTrue;
    Test('IsLoSurrogate($dcff)').Assert(Unicode.IsLoSurrogate(WideChar($dfff))).IsTrue;
  end;


  procedure Utils.SurrogatesToCodepointDecodesValidSurrogatesCorrectly;
  var
    sut: Codepoint;
  begin
    sut := Unicode.SurrogatesToCodepoint(#$d800, #$dc00);
    Test('SurrogatesToCodepoint($d800, $dc00)').Assert(sut).Equals($10000);

    sut := Unicode.SurrogatesToCodepoint(#$d801, #$dc37);
    Test('SurrogatesToCodepoint($d801, $dc37)').Assert(sut).Equals($10437);

    sut := Unicode.SurrogatesToCodepoint(#$d852, #$df62);
    Test('SurrogatesToCodepoint($d852, $df62)').Assert(sut).Equals($24b62);

    sut := Unicode.SurrogatesToCodepoint(#$dbff, #$dfff);
    Test('SurrogatesToCodepoint($dbff, $dfff)').Assert(sut).Equals($10ffff);
  end;


  procedure Utils.SurrogatesToCodepointRaisesEInvalidHiSurrogateIfHiSurrogateIsNotValid;
  begin
    Test.Raises(EInvalidHiSurrogate);
    Unicode.SurrogatesToCodepoint(#$df62, #$df62);
  end;


  procedure Utils.SurrogatesToCodepointRaisesEInvalidLoSurrogateIfLoSurrogateIsNotValid;
  begin
    Test.Raises(EInvalidLoSurrogate);
    Unicode.SurrogatesToCodepoint(#$d852, #$d852);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf16ToUtf8StringsEncodesValidStringCorrectly;
  var
    input: UnicodeString;
    result: Utf8String;
    expectedResult: Utf8String;
  begin
    input := '©2020??';
    input[6]  := #$d801;
    input[7]  := #$dc37;

    expectedResult := '??2020????';
    expectedResult[1]   := Utf8Char($c2);
    expectedResult[2]   := Utf8Char($a9);
    expectedResult[7]   := Utf8Char($f0);
    expectedResult[8]   := Utf8Char($90);
    expectedResult[9]   := Utf8Char($90);
    expectedResult[10]  := Utf8Char($b7);

    result := Unicode.Utf16ToUtf8(input);

    Test('Utf16ToUtf8({input})', [input]).AssertUtf8(result).Equals(expectedResult);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointEncodesValidUtf8Correctly;
  var
    cp: Codepoint;
  begin
    cp := Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$41]));
    Test('Utf8ToCodepoint([$41])').Assert(cp).Equals($41);

    cp := Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$c2, #$a9]));
    Test('Utf8ToCodepoint([$c2, $a9])').Assert(cp).Equals($a9);

    cp := Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$ed, #$95, #$9c]));
    Test('Utf8ToCodepoint([$ed, $95, $9c])').Assert(cp).Equals($d55c);

    cp := Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$f0, #$90, #$8d, #$88]));
    Test('Utf8ToCodepoint([$f0, $90, $8d, $88])').Assert(cp).Equals($10348);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointRaisesEInvalidEncodingIfByteIsNotAValidLeadByte;
  begin
    Test.Raises(EInvalidEncoding, '0xFF is not a valid byte in Utf8');
    Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$ff]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointRaisesEInvalidEncodingIfContinuationByteIsInvalid;
  begin
    Test.Raises(EInvalidEncoding, '0x20 is not a valid continuation byte');

    Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$c2, #$20]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointRaisesEInvalidEncodingIfFirstOfThreeContinuationBytesIsInvalid;
  begin
    Test.Raises(EInvalidEncoding, '0x20 is not a valid continuation byte');

    Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$f0, #$20, #$8d, #$88]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointRaisesEInvalidEncodingIfFirstOfTwoContinuationBytesIsInvalid;
  begin
    Test.Raises(EInvalidEncoding, '0x20 is not a valid continuation byte');

    Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$ed, #$20, #$9c]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointRaisesEInvalidEncodingIfSecondOfThreeContinuationBytesIsInvalid;
  begin
    Test.Raises(EInvalidEncoding, '0x20 is not a valid continuation byte');

    Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$f0, #$90, #$20, #$88]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointRaisesEInvalidEncodingIfSecondOfTwoContinuationBytesIsInvalid;
  begin
    Test.Raises(EInvalidEncoding, '0x20 is not a valid continuation byte');

    Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$ed, #$95, #$20]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointRaisesEInvalidEncodingIfThirdOfThreeContinuationBytesIsInvalid;
  begin
    Test.Raises(EInvalidEncoding, '0x20 is not a valid continuation byte');

    Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$f0, #$90, #$8d, #$20]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointRaisesEMoreDataIfAtLeastOneRequiredContinuationByteOfThreeIsNotAvailable;
  begin
    Test.Raises(EMoreData, '3 continuation bytes required, 2 available');

    Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$f0, #$90, #$8d]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointRaisesEMoreDataIfAtLeastOneRequiredContinuationByteOfTwoIsNotAvailable;
  begin
    Test.Raises(EMoreData, '2 continuation bytes required, 1 available');

    Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$ed, #$95]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointRaisesEMoreDataIfOneRequiredContinuationByteOfOneIsNotAvailable;
  begin
    Test.Raises(EMoreData, '1 continuation byte required, 0 available');

    Unicode.Utf8ToCodepoint(Unicode.Utf8Array([#$c2]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointRaisesENoData;
  begin
    Test.Raises(ENoData, 'No Utf8 characters available');

    Unicode.Utf8ToCodepoint(Unicode.Utf8Array([]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToUtf16StringsEncodesValidStringCorrectly;
  var
    input: Utf8String;
    result: UnicodeString;
    expectedResult: UnicodeString;
  begin
    expectedResult  := '©2020??';
    expectedResult[6] := #$d801;
    expectedResult[7] := #$dc37;

    input := '??2020????';
    input[1]  := Utf8Char($c2);
    input[2]  := Utf8Char($a9);
    input[7]  := Utf8Char($f0);
    input[8]  := Utf8Char($90);
    input[9]  := Utf8Char($90);
    input[10] := Utf8Char($b7);

    result := Unicode.Utf8ToUtf16(input);

    Test('Utf8ToUtf16({input})', [input]).Assert(result).Equals(expectedResult);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Utils.Utf8ToCodepointYieldsEmptyArrayIfInputArrayIsEmpty;
  var
    result: Utf8Array;
  begin
    result := Unicode.Utf8Array([]);

    Test('Length(result)').Assert(Length(result)).Equals(0);
  end;





end.
