using Unidecode.Core;

var cases = new (string Name, string Input, string Expected)[]
{
    ("Chinese", @"Hello \u4F60\u597D", "Hello 你好"),
    ("Lowercase hex", @"\u4f60", "你"),
    ("Surrogate pair", @"Smile: \uD83D\uDE00", "Smile: 😀"),
    ("Mixed content", @"A\u0020B / \u00A9", "A B / ©"),
    ("Incomplete escape", @"Keep \u123", @"Keep \u123"),
    ("Invalid hex", @"Keep \uZZZZ", @"Keep \uZZZZ"),
    ("Lone high surrogate", @"Keep \uD83D", @"Keep \uD83D"),
    ("Lone low surrogate", @"Keep \uDE00", @"Keep \uDE00"),
    ("Other escapes", @"Keep \n and \x41", @"Keep \n and \x41"),
    ("Empty", string.Empty, string.Empty),
};

var failures = 0;
foreach (var testCase in cases)
{
    var actual = UnicodeEscapeDecoder.Decode(testCase.Input);
    if (!string.Equals(actual, testCase.Expected, StringComparison.Ordinal))
    {
        Console.Error.WriteLine($"FAIL {testCase.Name}: expected <{testCase.Expected}>, got <{actual}>");
        failures++;
    }
}

if (failures > 0)
{
    Console.Error.WriteLine($"{failures} decoder test(s) failed.");
    return 1;
}

Console.WriteLine($"All {cases.Length} decoder tests passed.");
return 0;
