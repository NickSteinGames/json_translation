# JSONTranslation
## About
Its little script, what uses JSON files for adding they into TranslationServer.
A main feature of this script: It can process String, Arrays and Dictionary elements.
Root elements its a locate/language codes:
```json
{
  "en": { "English messages..." },
  "ru": { "Russian messages..." },
  "en-us": { "English (USA) messages..." },
}
```
And how processing of Arrays and Dictionaries works:
```json
{
  "en": {
    "string_item": "Hi! I'am a String!",
    "array_item": [
      "Hi!",
      "I'am",
      "an Array!"
    ],
    "dictionary_item.": {
      "part1": "I'am a Dictionary!",
      "part2": "And i have many lines!",
      "part3": ";P"
    },
    "multy_item.": {
      "variant1.": {
        "part1": "Hi!",
        "part2": "I am Dictionary...",
        "part3": "inside a Dictionary!"
      },
      "variant2.": [
        "Hi!",
        "I am Array...",
        "inside a Dictionary!"
      ]
    }
  }
}
```
After all, you got something like this:
```
"string_item" => "Hi! I'am a String!"

"array_item0" => "Hi!"
"array_item1" => "I'am"
"array_item2" => "an Array!"

"dictionary_item.part1" => "I'am a Dictionary!"
"dictionary_item.part2" => "And i have many lines!"
"dictionary_item.part3" => ";P"

"multy_item.variant1.part1" => "Hi!"
"multy_item.variant1.part2" => "I am Dictionary..."
"multy_item.variant1.part3" => "inside a Dictionary!"

"multy_item.variant2.0" => "Hi!"
"multy_item.variant2.1" => "I am Array..."
"multy_item.variant2.2" => "inside a Dictionary!"
```
Naming works like this:
 - if item is just a String: added it with item name.
 - if item is a Array: "`last_item_name` + `item_idx`" (`"array.": ["zero", "one"]` => `array.0 = "zero"; array.1 = "one"`)
 - if item is a Dictionary: "`last_item_name` + `item_name`"
## How to use?
Just call `JsonTranslation.load_tr()` in some script (`Game` or something like this)
```gdscript
JsonTranslation.load_tr("path_to_file/file_uid")
```
