CREATE TABLE Effects(
    Name TEXT PRIMARY KEY,
    Id TEXT,
    Effect TEXT,
    Magnitude NUMERIC,
    Value INTEGER);

CREATE TABLE Ingredients(
    Name TEXT PRIMARY KEY,
    Id TEXT,
    Weight NUMERIC,
    Value INTEGER);

CREATE TABLE HasEffect(
    Ingredient TEXT,
    Effect TEXT,
    FOREIGN KEY (Ingredient) REFERENCES Ingredients(Name),
    FOREIGN KEY (Effect) REFERENCES Effects(Name));

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

-- VIEW PairEffect(Ingredient1, Ingredient2, Effect)
-- If (Ingredient1, Ingredient2, Effect) is a row, (Ingredient2, Ingredient1, Effect) is a row.
CREATE VIEW PairEffect AS
    SELECT r1.Name AS Ingredient1, r2.Name AS Ingredient2, has1.Effect AS Effect
    FROM Ingredients r1, HasEffect has1, Ingredients r2, HasEffect has2
    WHERE r1.Name = has1.Ingredient AND r2.Name = has2.Ingredient AND has1.Effect = has2.Effect;

-- Like PairEffect,
-- But, if (Ingredient1, Ingredient2, Effect) is a row then (Ingredient2, Ingredient2, Effect) is not.
CREATE VIEW PairSetEffect AS
    SELECT p.Ingredient1 AS Ingredient1, p.Ingredient2 AS Ingredient2, p.Effect AS Effect
    FROM PairEffect p, Ingredients r1, Ingredients r2
    WHERE p.Ingredient1 = r1.Name AND p.Ingredient2 = r2.Name AND r1.Id < r2.Id;

CREATE VIEW TripleEffect AS
    SELECT p.Ingredient1 AS Ingredient1, p.Ingredient2 AS Ingredient2, r3.Name AS Ingredient3, p.Effect AS Effect
    FROM PairSetEffect p, Ingredients r2, Ingredients r3
    WHERE p.Ingredient2 = r2.Name AND r2.Id < r3.Id
    UNION
    SELECT r1.Name AS Ingredient1, p.Ingredient1 AS Ingredient2, p.Ingredient2 AS Ingredient3, p.Effect AS Effect
    FROM Ingredients r1, Ingredients r2, PairSetEffect p
    WHERE p.Ingredient1 = r2.Name AND r1.Id < r2.Id
    UNION
    SELECT p.Ingredient1 AS Ingredient1, r2.Name AS Ingredient2, p.Ingredient2 AS Ingredient3, p.Effect AS Effect
    FROM Ingredients r1, Ingredients r2, Ingredients r3, PairSetEffect p
    WHERE r1.Id < r2.Id AND r2.Id < r3.Id AND p.Ingredient1 = r1.Name AND p.Ingredient2 = r3.Name;

.separator ","
.import data/effects.csv Effects
.import data/ingredients.csv Ingredients
.import data/haseffect.csv HasEffect
