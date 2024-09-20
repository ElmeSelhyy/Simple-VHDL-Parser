# Simple Language Parser

## Overview

This project implements a simple language parser for a custom hardware description language using lex/yacc (flex/bison). The parser validates the syntax and semantics of input files according to specified language rules.

## Features

- Case-insensitive language processing
- Entity and architecture pair validation
- Signal declaration and assignment checking
- Type compatibility verification
- Comprehensive error reporting

## Prerequisites

- Linux operating system
- Flex (lex)
- Bison (yacc)
- GCC compiler
- Make utility

## Setup

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/simple-language-parser.git
   cd simple-language-parser
   ```

2. Ensure you have all the required tools installed. On Ubuntu or Debian-based systems, you can install them with:
   ```
   sudo apt-get update
   sudo apt-get install flex bison gcc make
   ```

3. Build the parser:
   ```
   make parser
   ```

## Usage

1. Create an input file with your hardware description language code. For example, `input.txt`:
   ```
   ENTITY myentity IS
   END;

   ARCHITECTURE myarch OF myentity IS
     SIGNAL s1 : t1;
     SIGNAL s2 : t1;
   BEGIN
     s1 <= s2;
   END;
   ```

2. Run the parser on your input file:
   ```
   ./parser < input.txt
   ```

3. The parser will validate the input and report any errors found.

## Running Tests

1. Place your test input files in the `tests` directory with a `.txt` extension.

2. Run the test script:
   ```
   ./testingScript.sh
   ```

   This will run the parser on all test files in the `tests` directory and display the results.

## Project Structure

- `lexer.l`: Flex file containing token definitions and lexical analysis rules
- `parser.y`: Bison file containing grammar rules and semantic actions
- `testingScript.sh`: Bash script for running test cases
- `Makefile`: Build configuration for the project
