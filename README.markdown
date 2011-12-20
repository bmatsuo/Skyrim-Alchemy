Skyrim Alchemy
==============

This project is a contains tools for potion recipe discovery in Skyrim.

Features
========

Currently, only a database backend is provided. Scripts and other programs will
be added to help search the database.

A backend database
------------------

Skyrim Alchemy uses an SQLite database to house alchemy information. This allows
the database to be downloaded as a standalone binary. SQLite databases can also
be used in iPhone (and Android?) applications.

A potion effect assistant (TODO)
--------------------------------

An application for discovering recipes for desired effect combinations.

A potion value optimizer (TODO)
-------------------------------

An application for discovering recipes for valuable potions (with any effects).

The alchemy database
====================

The alchemy database consists of several base tables, along with some higher level views.

Creating the database
---------------------

Run the makefile to generate the Skyrim Alchemy SQLite database.

    make [alchemy.sqlite]

This creates the database as a binary file `./alchemy.sqlite`.

Database tables
---------------

The following tables are available in the alchemy database.

**Effects(Name, Id, Effect, Magnitude, Value)**

Has all potion effects (names), their console Id, effect description, effect
magnitude (BUNK), and value (for a potion of the given magnitude).

See [Skyrim:Alchemy Effects](http://www.uesp.net/wiki/Skyrim:Alchemy_Effects)
and [Skyrim talk:Alchemy Effects](http://www.uesp.net/wiki/Skyrim_talk:Alchemy_Effects)
for more information about the Magnitude column.

**Ingredients(Name, Id, Weight, Value)**

Has all standard ingredients (names), their console Id, weight, and value in Septims.

Unique ingredients (Jarrin Root, and Berit's Ashes) are not included. There is
a unique Salt Pile (00074a19), but it has the same effects as a normal Salt Pile
(00034cdf). Berit's Ashes has the same effects as Bone Meal. Jarrin Root is
extremely powerful in poisons, but it is omitted from recipes in Skyrim Alchemy
because only one exists in the game.

See [Skyrim:Alchemy](http://www.uesp.net/wiki/Skyrim:Ingredients)

**HasEffect(Ingredient, Effect)**

The effects (names) of ingredients (names). Obviously, each ingredient is
present in 4 rows of of the relation.

Views
-----

Aside from the simple tables above, the alchemy database also provides some
views for simplifying common queries. Skyrim Alchemy provides the following
database views:

**IngredientEffects(Name, Effect1, Effect2, Effect3, Effect3)**

For each ingredient, this simple view aggregates the 4 corresponding rows of
HasEffect into a single row.

**PairEffect(Ingredient1, Ingredient2, Effect)**

This is a table of common effects shared between pairs of ingredients. The same
pair of ingredients can appear in multiple rows with different effects.

The order of the pair does not matter. Thus, If (Ingredient1, Ingredient2,
Effect) is a row, then (Ingredient2, Ingredient1, Effect) is a row.

**PairSetEffect(Ingredient1, Ingredient2, Effect)**

Like PairEffect, but ingredients pairs must be ordered by their console ids.
Thus, if (Ingredient1, Ingredient2, Effect) is a row, then (Ingredient2,
Ingredient2, Effect) is not.

**TripleEffect(Ingredient1, Ingredient2, Ingredient3, Effect)**

Rows are ingredient triples with effects shared by at least two of those
ingredients. The triple of ingredients must be ordered. The same triple of
ingredients can appear on multiple rows.

Querying the database
---------------------

To see the effects of a two-ingredient potion, say Deathbell + River Betty

    sqlite> SELECT Effect FROM PairEffect WHERE Ingredient1 = "Deathbell" AND Ingredient2 = "River Betty";
    Damage Health
    Slow
    sqlite>

To see the effects of a three-ingredient potion, say Deathbell + River Betty + Chaurus Eggs,
the ingredients first need to be sorted by ID

    sqlite> SELECT Name, Id
       ...> FROM Ingredients
       ...> WHERE Name = "Deathbell" OR Name = "River Betty" OR Name = "Chaurus Eggs"
       ...> ORDER BY Id ASC;
    Chaurus Eggs|0003ad56
    Deathbell|000516c8
    River Betty|00106e1a
    sqlite>

Then query the TripleEffect view, instead of the PairEffect view from the firt example

    sqlite> SELECT Effect
       ...> FROM TripleEffect
       ...> WHERE Ingredient1 = "Chaurus Eggs" AND Ingredient2 = "Deathbell" AND Ingredient3 = "River Betty";
    Damage Health
    Slow
    Weakness to Poison
    sqlite> 

To see all combinations of three ingredients which provide both Damage Health and Weakness to Poison
effects

    sqlite> SELECT r1.Name, r2.Name, r3.Name
       ...> FROM Ingredients r1, Ingredients r2, Ingredients r3
       ...> WHERE r1.Id < r2.Id AND r2.Id < r3.Id
       ...>      AND 2 <= (SELECT COUNT(*)
       ...>                FROM TripleEffect
       ...>                WHERE Ingredient1 = r1.Name AND Ingredient2 = r2.Name AND Ingredient3 = r3.Name
       ...>                      AND (Effect = "Damage Heath" OR Effect = "Weakness to Poison"));
