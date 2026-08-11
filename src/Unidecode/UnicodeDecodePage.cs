using Microsoft.CommandPalette.Extensions;
using Microsoft.CommandPalette.Extensions.Toolkit;
using Unidecode.Core;

namespace Unidecode;

internal sealed partial class UnicodeDecodePage : DynamicListPage
{
    public UnicodeDecodePage()
    {
        Icon = new IconInfo("\uE8D2");
        Title = "Unidecode";
        Name = "Decode";
    }

    public override void UpdateSearchText(string oldSearch, string newSearch) => RaiseItemsChanged();

    public override IListItem[] GetItems()
    {
        if (string.IsNullOrEmpty(SearchText))
        {
            return
            [
                new ListItem(new NoOpCommand())
                {
                    Title = @"Type text containing \uXXXX",
                    Subtitle = @"Example: Hello \u4F60\u597D",
                },
            ];
        }

        var decoded = UnicodeEscapeDecoder.Decode(SearchText);
        return
        [
            new ListItem(new CopyTextCommand(decoded))
            {
                Title = decoded,
                Subtitle = string.Equals(decoded, SearchText, StringComparison.Ordinal)
                    ? @"No valid \uXXXX sequence found"
                    : "Press Enter to copy the decoded text",
            },
        ];
    }
}
