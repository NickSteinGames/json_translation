# JSONTranslation

## About
**JSONTranslation** is a small GDScript utility that loads translations from JSON files into Godot Engine's `TranslationServer`.  
Its main feature is the ability to process not only simple strings but also nested arrays and dictionaries, automatically generating message keys with hierarchical names.

## Structure of the JSON file
The root keys of the JSON object are **locale codes** (e.g., `"en"`, `"ru"`, `"en-us"`). Each locale contains a dictionary of messages:

```json
{
  "en": { "English messages..." },
  "ru": { "Russian messages..." },
  "en-us": { "English (USA) messages..." }
}
```
## How messages are processed
The script traverses the structure recursively and builds translation keys according to the following rules:
- If the value is a String → the key is the current path (the concatenation of all parent keys).
- If the value is an Array → each element is processed with the key current_path + index.
- If the value is a Dictionary → each entry is processed with the key current_path + child_key.

Example
Given the following JSON:
```json
{
  "en": {
    "string_item": "Hi! I'm a String!",
    "array_item": [
      "Hi!",
      "I'm",
      "an Array!"
    ],
    "dictionary_item.": {
      "part1": "I'm a Dictionary!",
      "part2": "And I have many lines!",
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
After loading, the following translations become available:

```text
"string_item"               → "Hi! I'm a String!"

"array_item0"               → "Hi!"
"array_item1"               → "I'm"
"array_item2"               → "an Array!"

"dictionary_item.part1"     → "I'm a Dictionary!"
"dictionary_item.part2"     → "And I have many lines!"
"dictionary_item.part3"     → ";P"

"multy_item.variant1.part1" → "Hi!"
"multy_item.variant1.part2" → "I am Dictionary..."
"multy_item.variant1.part3" → "inside a Dictionary!"

"multy_item.variant2.0"     → "Hi!"
"multy_item.variant2.1"     → "I am Array..."
"multy_item.variant2.2"     → "inside a Dictionary!"
```

## Context
You can attach a context to any message by inserting `?<context>?` anywhere in the key name.
The context will be removed from the final message key and stored separately for use with `TranslationServer.translation()`.
### Examples
```json
{
  "en": {
    "text": "Hi! I am text!",
    "text?two?": "Hi! I am two texts!",

    "letter": "Letter",
    "letter_": {
      "a": "A Letter text.",
      "b": "B Letter text.",
      "c": "C Letter text."
    }
  },
  "ru": {
    "text": "Привет! Я текст!",
    "text?two?": "Привет! Я два текста!",

    "letter": "Письмо или Буква",
    "letter?Alphabet?": "Буква",
    "letter?Message?": "Письмо",

    "letter_": {
      "a?Alphabet?": "Буква A.",
      "a?Message?": "Текст письма A.",
      "b?Alphabet?": "Буква B.",
      "b?Message?": "Текст письма B.",
      "c?Alphabet?": "Буква C.",
      "c?Message?": "Текст письма C."
    }
  }
}
```
You can also apply context to whole groups by placing ?context? at the end of a dictionary key:

```json
"ru": {
  "letter_?Alphabet?": {
    "a": "Буква A.",
    "b": "Буква B.",
    "c": "Буква C."
  },
  "letter_?Message?": {
    "a": "Текст письма A.",
    "b": "Текст письма B.",
    "c": "Текст письма C."
  }
}
```
> [!NOTE]
> The context marker `?_?` can appear anywhere in the key; it will be stripped from the final message name.

> [!WARNING]
> Only one context per message is allowed. If multiple `?_?` patterns appear, they will be treated as part of a single context string.
> 
> ```json
> "letter?Message??Message001?": "Письмо 001"   → Context will be "Message??Message001"
> ```
> <img width="652" height="279" alt="Context preview" src="https://github.com/user-attachments/assets/8e154065-c280-4b0f-8554-5a1b62eeef67" />

## Usage
Simply call JsonTranslation.load_tr() somewhere in your project (e.g., in an autoload or main scene):

```gdscript
JsonTranslation.load_tr("res://path/to/your_translations.json")
```
The file path should be a Godot resource path (starting with `res://`) pointing to a valid `JSON` file.

## Exporting
When you export your project, Godot does not automatically include plain, including `.json` files.
To ensure your translation files are present in the exported game, you must manually add them to the Export Preset under the "Resources" tab:
 1. Open `Project` → `Export`.
 1. Select your export preset.
 1. Go to the `Resources` tab.
 1. In the `export non-resource files` section, add `*.json` (or the exact path to your translation file or folder with your file) to include JSON files.

## Debugging
You can enable debug output by setting `DEBUGGING = true` inside the script. It will print all loaded translations for each locale.

## Example of all features
```JSON
{
  "en": {
    "simple_string": "Just a simple string.",
    "array_of_strings": [
      "First element",
      "Second element",
      "Third element"
    ],
    "dictionary": {
      "key1": "Value 1",
      "key2": "Value 2",
      "key3": "Value 3"
    },
    "nested_array_in_dict": {
      "sub_array": [
        "Array inside dict 1",
        "Array inside dict 2"
      ]
    },
    "array_with_dicts": [
      {
        "dict_in_array_1": "First dict in array",
        "dict_in_array_2": "Second dict in array"
      },
      "just a string in array after dict"
    ],
    "deep_nesting": {
      "level1": {
        "level2": {
          "level3_string": "Deeply nested string"
        }
      },
      "level1_array": [
        {
          "level2_dict_in_array": {
            "level3_key": "Very deep"
          }
        }
      ]
    },
    "message?greeting?": "Hello with context!",
    "array_with_context": [
      "no context here",
      "?special?second element with context"
    ],
    "dict_with_context_keys": {
      "normal_key": "normal value",
      "key?special?": "value with context"
    },
    "group?shared?": {
      "item1": "This item has context 'shared'",
      "item2": "This item also has context 'shared'",
      "subgroup": {
        "subitem": "This subitem also inherits 'shared'"
      }
    },
    "parent?outer?": {
      "child?inner?": "This will have context 'outer?inner?'"
    },
    "array?array_context?": [
      "first element with array context",
      "second element with array context"
    ],
    "outer_array?outer_ctx?": [
      "plain string",
      [
        "inner array first",
        "inner array second"
      ],
      {
        "dict_in_array": "dict in array with outer_ctx"
      }
    ],
    "key.with.dot": "Value with dot in key"
  }
}
```
