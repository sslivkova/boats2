# boats2
Turn your Bots into HTML
![Example output](https://files.catbox.moe/18eogg.jpg)

## Description
boats2.pl is a utility to generate an HTML page to display Tavern character
cards. It will read all .png files from the input
directory, extract the data from them and render them as HTML based on a
customisable template. The program will organise the cards into categories,
based on the folder structure inside the input directory. It will write both
the rendered HTML and a copy of the card images to an output directory.

## Requirements
* [Perl](https://www.perl.org/get.html)
* [Libpng](https://metacpan.org/dist/Image-PNG-Libpng/view/lib/Image/PNG/Libpng.pod)

## Usage

Place your cards in the input directory and run the program with
`perl boats2.pl`.

You can categorize your cards by creating subdirectories inside the input
directory. One level of subdirectories is supported for categorization.
Your subdirectory names will become your category titles.

Cards not in any subdirectory will be rendered first and given the default
category title.

For example, a structure like this
```
input/
  bob.png
  jim.png
  category1/
    jeff.png
```
will become two categories, a default one and "category1". The default one has
a configurable title (see Configuration) and will appear above all other
categories, the rest of them being sorted in alphabetical order.


## Configuration
Edit `config.pl` to configure the script.
* `title`: The title of the default category (cards not in any subdirectory).
* `output_dir`: Destination directory.
* `card_output_dir`: Subdirectory of `output_dir` where your cards will be
copied to.
* `html_filename`: Name of output HTML file.

### Template customization
The script comes with a default template, however you can change this according
to how you want it.

#### Variables
Variables are used to access card information. Every field inside of "data"
can be called using `{% var field %}` if it is present in your cards.
Additionally the extra field `href` contains a relative path to the card
in the output.

#### Conditionals
Conditionals are used to check if a given value is defined or not.
Example: `{% if field %} Field has value! {% end %}`
will only render if `field` has a value.

Similarly, `{% if !field %} Field has no value... {% end %}` will render only
if `field` doesn't have a value.

Conditionals must always be terminated by `{% end %}`.

#### Loops
Loops let you iterate through your categories and the cards contained
within them, as well as array data in the cards: alt greetings and tags.

Example:
```
{% do categories %}
	<h2>{% category %}</h2>
{% end %}
```
would display every category title inside of a  \<h2\> tag.

Loops must always be terminated by `{% end %}`.
