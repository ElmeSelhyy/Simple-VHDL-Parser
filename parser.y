%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdarg.h>

void yyerror(const char *s);
int yylex();

extern int yylineno;
extern char *yytext;

typedef struct {
    char *name;
    char *type;
} Symbol;

typedef struct {
    Symbol *symbols;
    int size;
    int capacity;
} SymbolTable;

SymbolTable *symbol_table;
char *entity_name = NULL;
int error_count = 0;

void init_symbol_table();
void free_symbol_table();
bool add_symbol(const char *name, const char *type);
Symbol *find_symbol(const char *name);
void report_error(const char *format, ...);
bool is_valid_identifier(const char *id);
%}

%union {
    char *string;
    struct {
        char *name;
        char *type;
    } signal;
}

%token ENTITY ARCHITECTURE SIGNAL IS OF BEGIN_TOKEN END
%token ASSIGNMENT_OP EXIT_COMMAND UNRECOGNIZED
%token <string> IDENTIFIER INVALID_IDENTIFIER

%type <string> entity_identifier architecture_identifier
%type <signal> signal_declaration

%start design_file

%%

design_file
    : entity_declaration architecture_declaration
    | error { yyerrok; YYABORT; }
    ;

entity_declaration
    : ENTITY entity_identifier IS END ';'
    { entity_name = $2; }
    ;

architecture_declaration
    : ARCHITECTURE architecture_identifier OF IDENTIFIER IS
      signal_declarations
      BEGIN_TOKEN
      assignment_statements
      END ';'
    {
        if (strcmp(entity_name, $4) != 0) {
            report_error("\"%s\" doesn't match the declared entity name \"%s\"", $4, entity_name);
        }
        free($2);
        free($4);
    }
    ;

signal_declarations
    : signal_declaration signal_declarations
    | /* empty */
    ;

signal_declaration
    : SIGNAL IDENTIFIER ':' IDENTIFIER ';'
    {
        if (!add_symbol($2, $4)) {
            report_error("Signal \"%s\" is already defined", $2);
        }
        $$.name = $2;
        $$.type = $4;
    }
    | SIGNAL INVALID_IDENTIFIER ':' IDENTIFIER ';'
    {
        report_error("Invalid identifier \"%s\"", $2);
        $$.name = $2;
        $$.type = $4;
        YYERROR;
    }
    | error ';' { yyerrok; YYERROR; }
    ;

assignment_statements
    : assignment_statement assignment_statements
    | /* empty */
    ;

assignment_statement
    : IDENTIFIER ASSIGNMENT_OP IDENTIFIER ';'
    {
        Symbol *lhs = find_symbol($1);
        Symbol *rhs = find_symbol($3);
        
        if (!lhs) {
            report_error("Unknown signal \"%s\"", $1);
        } else if (!rhs) {
            report_error("Unknown signal \"%s\"", $3);
        } else if (strcmp(lhs->type, rhs->type) != 0) {
            report_error("Signal types don't match in assignment. LHS type \"%s\", RHS type \"%s\"", lhs->type, rhs->type);
        }
        free($1);
        free($3);
    }
    | error ';' { yyerrok; YYERROR; }
    ;

entity_identifier
    : IDENTIFIER { $$ = $1; }
    | INVALID_IDENTIFIER
    {
        report_error("Invalid entity identifier \"%s\"", $1);
        $$ = $1;
        YYERROR;
    }
    ;

architecture_identifier
    : IDENTIFIER { $$ = $1; }
    | INVALID_IDENTIFIER
    {
        report_error("Invalid architecture identifier \"%s\"", $1);
        $$ = $1;
        YYERROR;
    }
    ;

%%

void init_symbol_table() {
    symbol_table = malloc(sizeof(SymbolTable));
    symbol_table->capacity = 10;
    symbol_table->size = 0;
    symbol_table->symbols = malloc(symbol_table->capacity * sizeof(Symbol));
}

void free_symbol_table() {
    for (int i = 0; i < symbol_table->size; i++) {
        free(symbol_table->symbols[i].name);
        free(symbol_table->symbols[i].type);
    }
    free(symbol_table->symbols);
    free(symbol_table);
}

bool add_symbol(const char *name, const char *type) {
    if (find_symbol(name) != NULL) {
        return false;
    }
    
    if (symbol_table->size == symbol_table->capacity) {
        symbol_table->capacity *= 2;
        symbol_table->symbols = realloc(symbol_table->symbols, symbol_table->capacity * sizeof(Symbol));
    }
    
    Symbol *new_symbol = &symbol_table->symbols[symbol_table->size++];
    new_symbol->name = strdup(name);
    new_symbol->type = strdup(type);
    return true;
}

Symbol *find_symbol(const char *name) {
    for (int i = 0; i < symbol_table->size; i++) {
        if (strcmp(symbol_table->symbols[i].name, name) == 0) {
            return &symbol_table->symbols[i];
        }
    }
    return NULL;
}

void report_error(const char *format, ...) {
    va_list args;
    va_start(args, format);
    
    fprintf(stderr, "Error: ");
    vfprintf(stderr, format, args);
    fprintf(stderr, "\n");
    
    va_end(args);
    error_count++;
}

bool is_valid_identifier(const char *id) {
    if (!isalpha(id[0]) && id[0] != '_') return false;
    for (int i = 1; id[i] != '\0'; i++) {
        if (!isalnum(id[i]) && id[i] != '_') return false;
    }
    return true;
}

int main(void) {
    init_symbol_table();
    int result = yyparse();
    if (result == 0 && error_count == 0) {
        printf("Parsing completed successfully\n");
    } else {
        printf("Parsing failed with %d error(s)\n", error_count);
    }
    free_symbol_table();
    free(entity_name);
    return (result != 0 || error_count > 0);
}

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
    error_count++;
}