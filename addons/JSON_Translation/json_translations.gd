@abstract class_name JsonTranslation extends Object
## Loads [Translations] from [JSON]-files.
##
## A root items in [JSON] - is language codes/locates, what be used for adding into [TranslationServer].
##[codeblock lang=text]
##{
##    "en": { English messages... },
##    "ru": { Russian messages... },
##    "en-us": { English (USA) messages... },
##}
##[/codeblock]
## Items in locate items is a [code]"message":[/code] and message text can be just a [String] or [Array] of [Strings] or [Dictionary].[br]
## [b]How it works:[/b][br]
## ● if message text is a [String]: just added it into [Translation].[br]
## ● if message text is a [Array]: added every item from it into into [Translation] how 𾓺[code]{message}{item_idx} = {message_text}[/code].[br]
## ● if message text is a [Dictionary]: added every item from it into into [Translation] with adding item name in end of previous item name.[br]
## But... who said what items in [Array]s and [Dictionary]s must be just a [String]?[br]
## This all thing has a cycle. Its means, if you have something like this:
##[codeblock lang=text]
##{
##    "en": {
##        "string_item": "Hi! I'am a String!",
##        "array_item": [
##              "Hi!",
##              "I'am",
##              "an Array!"
##        ],
##        "dictionary_item.": {
##            "part1": "I'am a Dictionary!",
##            "part2": "And i have many lines!",
##            "part3": ";P"
##         },
##        "multy_item.": {
##            "variant1.": {
##                "part1": "Hi!",
##                "part2": "I am Dictionary...",
##                "part3": "inside a Dictionary!"
##            },
##            "variant2.": [
##                "Hi!",
##                "I am Array...",
##                "inside a Dictionary!"
##            ]
##        }
##    }
##}
##[/codeblock]
## you got this:
##[codeblock lang=text]
##"string_item" => "Hi! I'am a String!"
##
##"array_item0" => "Hi!"
##"array_item1" => "I'am"
##"array_item2" => "an Array!"
##
##"dictionary_item.part1" => "I'am a Dictionary!"
##"dictionary_item.part2" => "And i have many lines!"
##"dictionary_item.part3" => ";P"
##
##"multy_item.variant1.part1" => "Hi!"
##"multy_item.variant1.part2" => "I am Dictionary..."
##"multy_item.variant1.part3" => "inside a Dictionary!"
##
##"multy_item.variant2.0" => "Hi!"
##"multy_item.variant2.1" => "I am Array..."
##"multy_item.variant2.2" => "inside a Dictionary!"
##[/codeblock]

const DEBUGGING = false ## Print debug stuff?

## Loads [JSON] file and adds messages and strings from it.
static func load_tr(file: String):
	var json: JSON = load(file)
	var data: Dictionary = (json.data as Dictionary)
	
	for lang: String in data.keys():
		var translation: Translation = Translation.new()
		translation.locale = lang
		for message in data[lang].keys():
			if data[lang][message] is String: ## If message is String: Just put it innto Translation file.
				translation.add_message(message, data[lang][message])
			elif data[lang][message] is Array: ## If message is Array: Send it for procces by another function.
				process_array(translation, message, data[lang][message])
			elif data[lang][message] is Dictionary: ## If message is Dictionary: Send it for procces by another function.
				process_dict(translation, message, data[lang][message])
		
		TranslationServer.add_translation(translation)
		
		if DEBUGGING: ## Prints all messages and their translations.
			for message in translation.get_message_list():
				print("%s => \"%s\"" % [message, translation.get_message(message)])

## Process array-item from [JSON]-translation-file and adds messages and translations into translation file.
static func process_array(translation: Translation, src_name: String, array: Array):
	for item in array:
		if item is String:
			translation.add_message(src_name + str(array.find(item)), item)
		elif item is Array:
			process_array(translation, src_name + str(array.find(item)), item)
		elif item is Dictionary:
			process_dict(translation, src_name + str(array.find(item)), item)
## Process dictionary-item from [JSON]-translation-file and adds messages and translations into translation file.
static func process_dict(translation: Translation, src_name: String, dict: Dictionary):
	for item in dict.keys():
		if dict[item] is String:
			translation.add_message(src_name + str(item), dict[item])
		elif dict[item] is Array:
			process_array(translation, src_name + item, dict[item])
		elif dict[item] is Dictionary:
			process_dict(translation, src_name + item, dict[item])
