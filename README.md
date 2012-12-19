deblank - remove special characters from filenames
==================================================

`deblank` is a command line tool (written in [Ruby][Ruby])
that renames files and replaces or removes special characters
like spaces, parentheses, or umlauts.
The new filename will only contain the following characters:

    A-Z a-z 0-9 . _ -

Spaces are replaced by underscores, German umlauts and eszett are
transliterated, all other invalid characters are removed.

Examples
--------

Use the program as shown in the examples below.

* `deblank "no space (and parentheses) allowed.txt"`

    renames the file to `no_space_and_parentheses_allowed.txt`

* `deblank "path with spaces/schrödinger.jpg"`

    renames the file to `path with spaces/schroedinger.jpg`

* `deblank -n "no space.txt"`

    no-act mode, only shows what would happen

* `deblank -l`

    lists the used character substitutions

Installation
------------

You can either

- clone or download the `deblank` repository and
  use `[sudo] rake install` to install `deblank`
  and its man page to `/usr/local`,

- copy `lib/deblank.rb` under the name `deblank` into your search path,

- put `lib/deblank.rb` anywhere and invoke it using its full path.

Requirements
------------

- Ruby must be installed on your system.

- No additional Ruby gems are needed to run `deblank`.

- `deblank` has been tested with Ruby 1.9.3 on a Linux machine
  and on Windows (command prompt with code page 850).

Documentation
-------------

Use `deblank --help` to display a brief help message.

If you installed `deblank` using `rake install` you can read
its man page with `man deblank`.

Known problems
--------------

With the Windows command prompt, depending on the used character
code page there might occur problems due to misinterpreted encoding
of command line arguments.

Reporting bugs
--------------

Report bugs on the `deblank` home page: <https://github.com/stomar/deblank/>

License
-------

Copyright &copy; 2012, Marcus Stollsteimer

`deblank` is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 3 or later (GPLv3+),
see [www.gnu.org/licenses/gpl.html](http://www.gnu.org/licenses/gpl.html).
There is NO WARRANTY, to the extent permitted by law.


[Ruby]: http://www.ruby-lang.org/
