-- TABLE Effects(Name, Id, Effect, Magnitude, Value)
-- Alchemy effect information. The value is for a single-effect potion with the given magnitude.
-- Produced magnitudes (and thus, gold values) can vary depending on the ingredients used.
CREATE TABLE Effects(
    Name TEXT PRIMARY KEY,
    Id TEXT,
    Effect TEXT,
    Magnitude NUMERIC,
    Value INTEGER);

-- TABLE Ingredients(Name, Id, Weight, Value)
-- The inventory-related information for each (non-unique) ingredient in Skyrim.
CREATE TABLE Ingredients(
    Name TEXT PRIMARY KEY,
    Id TEXT,
    Weight NUMERIC,
    Value INTEGER);

-- TABLE HasEffect(Ingredient, Effect)
-- A row maps an ingredient's name to one of its for effects.
CREATE TABLE HasEffect(
    Ingredient TEXT,
    Effect TEXT,
    FOREIGN KEY (Ingredient) REFERENCES Ingredients(Name),
    FOREIGN KEY (Effect) REFERENCES Effects(Name));

-- VIEW IngredientEffects(Name, Effect1, Effect2, Effect3, Effect4)
-- Aggregates the 4 effects of an ingredient into a single row.
CREATE VIEW IngredientEffects AS 
    SELECT r.Name As Name,
        has1.Effect AS Effect1, has2.Effect AS Effect2, has3.Effect AS Effect3, has4.Effect AS Effect4
    FROM Ingredients r,
        HasEffect has1, Effects e1,
        HasEffect has2, Effects e2,
        HasEffect has3, Effects e3,
        HasEffect has4, Effects e4
    WHERE r.Name = has1.Ingredient AND r.Name = has2.Ingredient AND r.Name = has3.Ingredient AND r.Name = has4.Ingredient
        AND has1.Effect = e1.Name AND has2.Effect = e2.Name AND has3.Effect = e3.Name AND has4.Effect = e4.Name
        AND e1.Id < e2.Id AND e2.Id < e3.Id AND e3.Id < e4.Id;

-- VIEW PairEffects(Ingredient1, Ingredient2, Effect)
-- If (Ingredient1, Ingredient2, Effect) is a row, (Ingredient2, Ingredient1, Effect) is a row.
CREATE VIEW PairEffects AS
    SELECT has2.Ingredient AS Ingredient1, has2.Ingredient AS Ingredient2, has1.Effect AS Effect
    FROM HasEffect has1, HasEffect has2
    WHERE has1.Effect = has2.Effect AND has1.Ingredient <> has2.Ingredient;

-- VIEW PairSetEffects(Ingredient1, Ingredient2, Effect)
-- Like PairEffect, row ingredients (names) are ordered by their ingredient id.
CREATE VIEW PairSetEffects AS
    SELECT has1.Ingredient AS Ingredient1, has2.Ingredient AS Ingredient2, has1.Effect AS Effect
    FROM HasEffect has1, HasEffect has2
    WHERE (SELECT Id FROM Ingredients WHERE Name = has1.Ingredient) < (SELECT Id FROM Ingredients WHERE Name = has2.Ingredient)
        AND has1.Effect = has2.Effect;

CREATE VIEW TripleEffects AS
    SELECT r1.Name AS Ingredient1, r2.Name AS Ingredient2, r3.Name AS Ingredient3, e.name AS Effect
    FROM Ingredients r1, Ingredients r2, Ingredients r3, Effects e
    WHERE r1.Id < r2.Id AND r2.Id < r3.Id
        AND EXISTS
            (SELECT *
            FROM PairSetEffects
            WHERE Effect = e.Name
                AND (Ingredient1 = r1.Name AND Ingredient2 = r2.Name
                    OR Ingredient1 = r1.Name AND Ingredient2 = r3.Name
                    OR Ingredient1 = r2.Name AND Ingredient2 = r3.Name));

--CREATE VIEW Potions AS
--    SELECT p.Ingredient1 AS Ingredient1, p.Ingredient2 AS Ingredient2, p.Ingredient3 AS Ingredient3,
--        (SELECT COUNT(*) FROM Effects WHERE Name IN
--            (SELECT Effect FROM PairEffects WHERE Ingredient1 = p.Ingredient1 AND Ingredient2 = p.Ingredient2
--            UNION SELECT Effect FROM PairEffects WHERE Ingredient1 = p.Ingredient1 AND Ingredient2 = p.Ingredient3
--            UNION SELECT Effect FROM PairEffects WHERE Ingredient1 = p.Ingredient2 AND Ingredient2 = p.Ingredient3)) AS NumEffects,
--        (SELECT SUM(Value) FROM Effects WHERE Name IN
--            (SELECT Effect FROM PairEffects WHERE Ingredient1 = p.Ingredient1 AND Ingredient2 = p.Ingredient2
--            UNION SELECT Effect FROM PairEffects WHERE Ingredient1 = p.Ingredient1 AND Ingredient2 = p.Ingredient3
--            UNION SELECT Effect FROM PairEffects WHERE Ingredient1 = p.Ingredient2 AND Ingredient2 = p.Ingredient3)) AS Value
--    FROM TripleEffects p

.separator ","
.import data/effects.csv Effects
.import data/ingredients.csv Ingredients
.import data/haseffect.csv HasEffect
