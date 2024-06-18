--creating tabless Pokedes, Trainer, Pokeball, Arena, Battles and Pokeball history	

--table Pokedex stores information about all Pokemons
CREATE TABLE Pokedex (
  name VARCHAR(25) CONSTRAINT name_pk PRIMARY KEY, 
  p_type VARCHAR(10) CONSTRAINT p_type_n NOT NULL,
  hp INTEGER CONSTRAINT hp_n NOT NULL,
  attack INTEGER CONSTRAINT attack_n NOT NULL,
  defence INTEGER CONSTRAINT defence_n NOT NULL,
  special_attack INTEGER CONSTRAINT special_attack NOT NULL,
  special_defence INTEGER CONSTRAINT special_defence NOT NULL);

--table Trainer stores information about all existing Trainers
CREATE TABLE Trainer (
  trainer_id INTEGER CONSTRAINT trainer_id_pk PRIMARY KEY,
  trainer_name VARCHAR(50) CONSTRAINT trainer_name_n NOT NULL);

--table Pokeball stores information about caught Pokemons and their Trainers
CREATE TABLE Pokeball (
  belong_to INTEGER CONSTRAINT belong_to NOT NULL CONSTRAINT belong_to_fk REFERENCES Trainer(trainer_id),
  pokemon VARCHAR(25) CONSTRAINT pokemon_fk REFERENCES Pokedex(name));

--table Arena stores information about available Arenas for training or battling Trainer's Pokemons
CREATE TABLE Arena (
  arena_id INTEGER CONSTRAINT arena_id_pk PRIMARY KEY,
  arena_name VARCHAR(25) CONSTRAINT arena_name_n NOT NULL,
  arena_type VARCHAR(10),
  region VARCHAR(15) CONSTRAINT region_n NOT NULL);

--table Battles stores information about the past and scheduled battles
CREATE TABLE Battles (
  battle_id INTEGER CONSTRAINT battle_id_pk PRIMARY KEY,
  arena INTEGER CONSTRAINT arena_fk REFERENCES Arena(arena_id),
  challenger INTEGER CONSTRAINT challenger_fk REFERENCES Trainer(trainer_id),
  defender INTEGER CONSTRAINT defender_fk REFERENCES Trainer(trainer_id),
  winner INTEGER CONSTRAINT winner_fk REFERENCES Trainer(trainer_id));

--table Pokeball_history keeps track of available Pokemons, i.e. Pokemon already caught by some Trainer cannot be caught again
CREATE TABLE Pokeball_history (
  log_id INTEGER CONSTRAINT log_id_pk PRIMARY KEY,
  pokemon VARCHAR(25),
  trainer INTEGER CONSTRAINT trainer_fk REFERENCES Trainer(trainer_id),
  caught_date DATE DEFAULT SYSDATE,
  release_date DATE);

--creating sequences
CREATE SEQUENCE seq_trainer_id;
CREATE SEQUENCE seq_battle_id;
CREATE SEQUENCE seq_arena_id;
CREATE SEQUENCE seq_log_id;

--creating trigger for checking if Pokemon in Pokeball exists in Pokedex
CREATE OR REPLACE TRIGGER check_pokemon BEFORE INSERT ON Pokeball FOR EACH ROW
DECLARE
  found_pokemon INTEGER;
BEGIN
  SELECT COUNT(name) INTO found_pokemon FROM Pokedex WHERE name = :new.pokemon;

  IF found_pokemon = 0 THEN RAISE VALUE_ERROR;
  END IF;
END;
/

--creating trigger for checking whether the challenger and defener have at least one pokemon in Pokeball
CREATE OR REPLACE TRIGGER check_challenger_and_deffENDer AFTER INSERT ON Battles FOR EACH ROW
DECLARE
  challenger_check INTEGER;
  defender_check INTEGER;
BEGIN 
  SELECT COUNT(belong_to) INTO challenger_check FROM Pokeball WHERE belong_to = :new.challenger;
  SELECT COUNT(belong_to) INTO defender_check FROM Pokeball WHERE belong_to = :new.defender;
	
  IF challenger_check = 0 OR defender_check = 0 OR :new.challenger = :new.defender THEN RAISE VALUE_ERROR;
  END IF;
END;
/

--creating trigger for checking release date of the Pokemon in Pokeball_history table
CREATE OR REPLACE trigger check_release_date AFTER INSERT OR UPDATE ON Pokeball_history FOR EACH ROW
BEGIN
  IF (:new.release_date is NOT NULL) AND (:new.release_date < :new.caught_date)
    THEN RAISE VALUE_ERROR;
  END IF;
END;
/


--creating trigger for logging caught Pokemons into Pokeball_history
CREATE OR REPLACE trigger caught_and_released_check AFTER INSERT OR DELETE ON Pokeball FOR EACH ROW
BEGIN 
  IF INSERTING THEN
    INSERT INTO Pokeball_history (log_id, pokemon, trainer) VALUES (seq_log_id.nextval, :new.pokemon, :new.belong_to);
  END IF;

  IF DELETING THEN
    UPDATE Pokeball_history SET release_date = SYSDATE WHERE :old.pokemon = Pokeball_history.pokemon;
  END IF;
END;
/

--inserting values into table Pokedex
INSERT INTO Pokedex VALUES ('Bulbasaur', 'Grass', 45, 49, 49, 65, 65);
INSERT INTO Pokedex VALUES ('Charizard', 'Fire', 78, 84, 78, 109, 85);
INSERT INTO Pokedex VALUES ('Squirtle', 'Water', 44, 48, 65, 50, 64);
INSERT INTO Pokedex VALUES ('Metapod', 'Bug', 50, 20, 55, 25, 25);
INSERT INTO Pokedex VALUES ('Beedrill', 'Bug', 65, 90, 40, 45, 80);
INSERT INTO Pokedex VALUES ('Rattata', 'NORmal', 30, 56, 35, 25, 35);
INSERT INTO Pokedex VALUES ('Pikachu', 'Electric', 35, 55, 40, 50, 50);
INSERT INTO Pokedex VALUES ('Clefairy', 'Fairy', 70, 45, 48, 60, 65);
INSERT INTO Pokedex VALUES ('Vulpix', 'Fire', 38, 41, 40, 50, 65);
INSERT INTO Pokedex VALUES ('Jigglypuff', 'NORmal', 115, 45, 20, 45, 25);
INSERT INTO Pokedex VALUES ('Psyduck', 'Water', 50, 52, 48, 65, 50);
INSERT INTO Pokedex VALUES ('Machoke', 'Fighting', 80, 100, 70, 50, 60);
INSERT INTO Pokedex VALUES ('Golem', 'Rock', 80, 120, 130, 55, 65);
INSERT INTO Pokedex VALUES ('Ponyta', 'Fire', 50, 85, 55, 65, 65);
INSERT INTO Pokedex VALUES ('Magneton', 'Electric', 50, 60, 95, 120, 70);
INSERT INTO Pokedex VALUES ('Gengar', 'Ghost', 60, 65, 60, 130, 75);
INSERT INTO Pokedex VALUES ('Hypno', 'Psychic', 85, 73, 70, 73, 115);
INSERT INTO Pokedex VALUES ('Jynx', 'Ice', 65, 50, 35, 115, 95);
INSERT INTO Pokedex VALUES ('Gyarados', 'Water', 95, 125, 79, 60, 100);
INSERT INTO Pokedex VALUES ('Eevee', 'NORmal', 55, 55, 50, 45, 65);
INSERT INTO Pokedex VALUES ('Snorlax', 'NORmal', 160, 110, 65, 65, 110);
INSERT INTO Pokedex VALUES ('Meowth', 'NORmal', 40, 45, 35, 40, 40);

--inserting values into table Trainer
INSERT INTO Trainer VALUES (seq_trainer_id.nextval, 'Ash Ketchum');
INSERT INTO Trainer VALUES (seq_trainer_id.nextval, 'Brock');
INSERT INTO Trainer VALUES (seq_trainer_id.nextval, 'James');
INSERT INTO Trainer VALUES (seq_trainer_id.nextval, 'ProfessOR Oak');
INSERT INTO Trainer VALUES (seq_trainer_id.nextval, 'Jessie');

--inserting values into table Pokeball
INSERT INTO Pokeball VALUES (1, 'Pikachu'); 
INSERT INTO Pokeball VALUES (2, 'Golem');
INSERT INTO Pokeball VALUES (3, 'Meowth');
INSERT INTO Pokeball VALUES (1, 'Jigglypuff');
INSERT INTO Pokeball VALUES (4, 'Charizard');
INSERT INTO Pokeball VALUES (3, 'Hypno');
INSERT INTO Pokeball VALUES (2, 'Snorlax');

--inserting values into table Arena
INSERT INTO Arena VALUES (seq_arena_id.nextval, 'Pewter City Gym', 'Rock', 'Kanto');
INSERT INTO Arena VALUES (seq_arena_id.nextval, 'Snowpoint Gym', 'Ice', 'Sinnoh');
INSERT INTO Arena VALUES (seq_arena_id.nextval, 'Nimbasa Gym', 'Electric', 'Unova');

--inserting values into table Battles
INSERT INTO Battles VALUES (seq_battle_id.nextval, 1, 2, 1, 2);
INSERT INTO Battles VALUES (seq_battle_id.nextval, 2, 3, 1, 1);
INSERT INTO Battles VALUES (seq_battle_id.nextval, 1, 3, 4, 4);

--inserting values into table Pokeball
DELETE FROM Pokeball WHERE pokemon = 'Charizard';
DELETE FROM Pokeball WHERE pokemon = 'Jigglypuff';
DELETE FROM Pokeball WHERE pokemon = 'Hypno';

--inserting values into table Pokeball
INSERT INTO Pokeball VALUES (5, 'Vulpix');
INSERT INTO Pokeball VALUES (3, 'Magneton');
INSERT INTO Pokeball VALUES (2, 'Rattata');
INSERT INTO Pokeball VALUES (4, 'Psyduck');
INSERT INTO Pokeball VALUES (1, 'Clefairy');
INSERT INTO Pokeball VALUES (4, 'Eevee');
INSERT INTO Pokeball VALUES (3, 'Jynx');
INSERT INTO Pokeball VALUES (4, 'Hypno');
INSERT INTO Pokeball VALUES (2, 'Squirtle');
INSERT INTO Pokeball VALUES (2, 'Charizard');
INSERT INTO Pokeball VALUES (1, 'Gyarados');

--inserting values into table Battles
INSERT INTO Battles VALUES (seq_battle_id.nextval, 3, 1, 2, 1);
INSERT INTO Battles VALUES (seq_battle_id.nextval, 3, 4, 1, 4);
INSERT INTO Battles VALUES (seq_battle_id.nextval, 2, 2, 3, 2);
INSERT INTO Battles VALUES (seq_battle_id.nextval, 1, 5, 1, 1);
INSERT INTO Battles VALUES (seq_battle_id.nextval, 1, 5, 4, 4);


--deleting values from table Pokeball
DELETE FROM Pokeball WHERE pokemon = 'Gyarados';
DELETE FROM Pokeball WHERE pokemon = 'Clefairy';
DELETE FROM Pokeball WHERE pokemon = 'Squirtle';

--inserting values into table Pokeball
INSERT INTO Pokeball VALUES (2, 'Gyarados');
INSERT INTO Pokeball VALUES (5, 'Machoke');
INSERT INTO Pokeball VALUES (4, 'Beedrill');


--arena with the wins of Ash Ketchum
SELECT COUNT(Arena.arena_name) AS number_of_wins, Arena.arena_name, Arena.arena_type 
FROM Arena JOIN Battles ON Arena.arena_id = Battles.arena JOIN Trainer ON Battles.winner = Trainer.trainer_id 
WHERE Trainer.trainer_name = 'Ash Ketchum' 
GROUP BY Arena.arena_name, Arena.arena_type
ORDER BY number_of_wins DESC;

--the most often caught Pokemon with its last/current Trainer
CREATE VIEW most_caught_pokemon_view AS 
SELECT COUNT(Pokeball_history.pokemon) AS caught, Pokeball_history.pokemon
FROM Pokeball_history
GROUP BY Pokeball_history.pokemon
HAVING COUNT(Pokeball_history.pokemon) = (SELECT MAX(caught) FROM (SELECT COUNT(pokemon) AS caught FROM Pokeball_history GROUP BY pokemon));

CREATE VIEW max_log_view AS
SELECT pokemon, trainer_name AS trainer
FROM Pokeball_history
JOIN Trainer
ON Pokeball_history.trainer = Trainer.trainer_id
WHERE log_id = (SELECT MAX(log_id) FROM Pokeball_history WHERE pokemon = (SELECT pokemon FROM most_caught_pokemon_view WHERE ROWNUM = 1)) 
GROUP BY pokemon, trainer_name;

SELECT most_caught.caught, most_caught.pokemon, max_log.trainer
FROM most_caught_pokemon_view most_caught
JOIN max_log_view max_log
ON most_caught.pokemon = max_log.pokemon;

--Trainer with the most Pokemons
SELECT COUNT(trainer_name) AS number_of_pokemons, Trainer.trainer_name 
FROM Pokeball 
JOIN Trainer 
ON Pokeball.belong_to = Trainer.trainer_id 
GROUP BY trainer_name 
HAVING COUNT(trainer_name) = (SELECT MAX(trainer) FROM (SELECT COUNT(belong_to) AS trainer FROM Pokeball GROUP BY belong_to));

--printing pokemons of the Trainer with the most pokemons
CREATE OR REPLACE procedure print_pokemons is
CURSOR trainer_with_most_pokemons is 
  SELECT Trainer.trainer_name, Pokeball.pokemon 
  FROM Pokeball 
  JOIN Trainer 
  ON Pokeball.belong_to = Trainer.trainer_id 
  WHERE belong_to = (SELECT belong_to FROM Pokeball GROUP BY belong_to HAVING COUNT(belong_to) = (SELECT MAX(id) FROM (SELECT COUNT(belong_to) AS id FROM Pokeball GROUP BY belong_to)));

BEGIN
  FOR pokemon in trainer_with_most_pokemons LOOP
    DBMS_OUTPUT.PUT_LINE(pokemon.trainer_name || ' has: ' || pokemon.pokemon);
  END LOOP;
END;
/

EXEC print_pokemons;
