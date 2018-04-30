
--Create by: Andrew Maklingham
--Date: 02/03/2018 (DD/MM/YYYY)

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.unbounded.Text_IO; use Ada.Strings.unbounded.Text_IO;
with Ada.Strings.Maps.Constants; use Ada.Strings.Maps.Constants;

--This is the main procedure of the program. This program reads a dictionary file
--stores each word in a array of unbounded strings, then asks the user to enter
--jumbles. It will then take these jumbles and get every possible anagram and see
--if any match with words from the dictionary file.
procedure jumble is
    size : integer := 0;
    fin, userSize, base : integer := 1;
    userStr, amount : unbounded_string;
    type vector is array (integer range <>) of unbounded_string;

    --arraySize
    --This function reads the dictionary file and returns the amount of lines present in it.
    --@param: integer: n = this is the value that will be assigned to return as 1 parameter is neeeded
    --@return: integer: n = this as the size of how many words are in the dictionary file
    function arraySize(n : in out integer) return integer is
        infp : file_type;
        str : unbounded_string;
        count : integer := 0;
    begin
        --open the file and see how many lines there are, then return that number
        open(infp, in_file, "/usr/share/dict/canadian-english-small");
        loop
            exit when end_of_file(infp);
            declare
                Line :unbounded_string := get_line(infp);
            begin
                count := count + 1;
            end;
        end loop;
        close(infp);
        n := count;
        return n;
    end arraySize;

    --buildLEXICON
    --The purpose of this procedure is to build the dictionary array.
    --@param: integer: size = this is the amount of lines in the dictionary file
    --@param: vector: dict = this is the array that each word from the dictionary file will be stored in
    procedure buildLEXICON(size : in out integer; dict : in out vector) is
        infp : file_type;
        num : integer := 1;
    begin
        --open then reads the file, line by line, storing each line as a unbounded string in array
        open(infp, in_file, "/usr/share/dict/canadian-english-small");
        loop
            exit when end_of_file(infp);
            dict(num) := get_line(infp);
            num := num + 1;
        end loop;
        close(infp);
    end buildLEXICON;

    --inputJumble
    --This asks the user to enter the jumbled letters and enters them into a array
    --@param: vector: jumArray = the array that holds the set of jumbled strings from the user
    --@param: integer: num = the amount of jumbled words the user will enter
    procedure inputJumble(jumArray : in out vector; num : in out integer) is
        result : unbounded_string;
        count : integer := 1;
    begin
        --asks the user to enter a jumbled sequence for as many times as the user inputed before
        while count <= num loop
            put("Please enter a jumbled word: ");
            get_line(result);
            --make the entered jumble lowercase
            translate(result, Lower_case_map);
            jumArray(count) := result;
            count := count + 1;
        end loop;
    end inputJumble;

    --findAnagram
    --This is a function that searches the dictionary array for a match with the current
    --anagram. If it finds a match, it will print it.
    --@param: unbounded_string: str = This is the anagram string to be compared with the dictionary array
    --@param: vector: dict = this is the dictionary array holding all the words
    --@size: integer: size = this is the dictionary array size
    procedure findAnagram(str : in unbounded_string; dict : in out vector; size : in integer) is
        i : integer := 1;
    begin
        --loop to iterate through each word in the dictionary array
        while i <= size loop
            --first check if they are the same length, then compare
            if length(str) = length(dict(i)) then
                if str = dict(i) then
                    put_line(str);
                end if;
            end if;
            i := i + 1;
        end loop;
    end findAnagram;

    --generateAnagram
    --This is the generateAnagram function. It's purpose is to generate the anagrams
    --from the letters of each jumbled words.
    --@param: vector: dict = this is the dictionary array holding all the words to be searched
    --@param: unbounded_string: str = this is the anagram string to be swapped and compared for a match
    --@param: integer: l, r = postions in the string to be checked or swapped
    --@param: integer: size = total size of the dictionary array for match purposes
    procedure generateAnagram(dict : in out vector; str : in out unbounded_string; l : in integer; r : in integer; size : in integer) is
        i : integer;

        --swap
        --This is the swap function that is used with generateAnagram.
        --@param: unbounded_string: str = anagram string to be swapped
        --@param: integer: l, r = positions on anagram string to be swapped
        procedure swap(str : in out unbounded_string; l : in integer; r : in integer) is
            temp : character := element(str, l);
        begin
            replace_element(str, l, element(str, r));
            replace_element(str, r, temp);
        end swap;

    begin
        if l = r then
            --if the end of one swap is reached, a new anagram is produced
            --send it to the findAnagram function to search for it in the dictionary
            findAnagram(str, dict, size);
        else
            i := l;
            while i <= r loop
                --swap the letters from position l and i, then recursively send it into generateAnagram
                swap(str, l, i);
                generateAnagram(dict, str, l+1, r, size);
                --revert it back after the swap
                swap(str, l, i);
                i := i + 1;
            end loop;
        end if;
    end generateAnagram;

begin
    --Introduce the program and tell user what to do
    put("Welcome to the Word Jumble program!");
    new_line;
    put("Loading the library may take a few moments.");
    new_line;
    --get size of the dictionary
    size := arraySize(size);
    --Once the size of the dictionary is found, allocate the array size
    declare
        dict : vector(1..size);
    begin
        --Create the library from the dictionary file, and store it in a array of unbounded strings
        buildLEXICON(size, dict);
        loop
            --Ask user how many jumbled words they will enter for current set
            new_line;
            put_line("Enter 0 to end program before typing jumbles.");
            new_line;
            put("How many jumbled words will be entered: ");
            get_line(amount);
            fin := Integer'Value (To_String(amount));
            --If user enters 0, quit the loop and end program
            if fin = 0 then
                exit;
            end if;
            --Once the amount of words that will be entered is got, it will when start the
            --word jumble input and the anagram finder
            declare
                jumArray : vector(1..fin);
                len : integer := 0;
                input : unbounded_string;
            begin
                inputJumble(jumArray, fin);
                userSize := 1;
                while userSize <= fin loop
                    len := length(jumArray(userSize));
                    input := jumArray(userSize);
                    put(input);
                    put(":   ");
                    new_line;
                    generateAnagram(dict, input, base, len, size);
                    new_line;
                    userSize := userSize + 1;
                end loop;
            end;
        end loop;
    end;
end jumble;
