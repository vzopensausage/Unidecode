using System.Globalization;
using System.Text;

namespace Unidecode.Core;

public static class UnicodeEscapeDecoder
{
    private const int EscapeLength = 6;

    public static string Decode(string input)
    {
        ArgumentNullException.ThrowIfNull(input);

        if (input.Length < EscapeLength)
        {
            return input;
        }

        var result = new StringBuilder(input.Length);

        for (var index = 0; index < input.Length;)
        {
            if (!TryReadEscape(input, index, out var value))
            {
                result.Append(input[index]);
                index++;
                continue;
            }

            var character = (char)value;
            if (char.IsHighSurrogate(character))
            {
                var nextIndex = index + EscapeLength;
                if (TryReadEscape(input, nextIndex, out var lowValue) &&
                    char.IsLowSurrogate((char)lowValue))
                {
                    result.Append(character);
                    result.Append((char)lowValue);
                    index += EscapeLength * 2;
                    continue;
                }

                result.Append(input, index, EscapeLength);
                index += EscapeLength;
                continue;
            }

            if (char.IsLowSurrogate(character))
            {
                result.Append(input, index, EscapeLength);
                index += EscapeLength;
                continue;
            }

            result.Append(character);
            index += EscapeLength;
        }

        return result.ToString();
    }

    private static bool TryReadEscape(string input, int index, out ushort value)
    {
        value = 0;
        return index >= 0 &&
               index + EscapeLength <= input.Length &&
               input[index] == '\\' &&
               input[index + 1] == 'u' &&
               ushort.TryParse(
                   input.AsSpan(index + 2, 4),
                   NumberStyles.AllowHexSpecifier,
                   CultureInfo.InvariantCulture,
                   out value);
    }
}
