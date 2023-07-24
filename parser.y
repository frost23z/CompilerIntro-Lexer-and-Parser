%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "ast.h"

    void yyerror(const char* s);
    extern int yylex(void);
    
    struct ASTNode* root = NULL;
%}

%union
{
    int inum_value;
    float fnum_value;
    char char_value;
    char* str_value;
    struct ASTNode* node_ptr;
}

%token <inum_value> INUM
%token <fnum_value> FNUM
%token <str_value> IDENTIFIER CHARLIT
%token INT CHAR FLOAT PRINT ASSIGN PLUS MINUS SEMICOLON

%left PLUS MINUS

%start program

%%

program:
    program statements
    | /* empty */
    ;

statements:
    variable_declaration
    | variable_initialization
    | print_statement
    ;

variable_declaration:
    IDENTIFIER variable_type SEMICOLON
    ;

variable_type:
    INT
    | CHAR
    | FLOAT
    ;

variable_initialization:
    IDENTIFIER ASSIGN value SEMICOLON
    ;

value:
    INUM
    | FNUM
    | CHARLIT
    | expression
    ;

expression:
    expression PLUS expression
    | expression MINUS expression
    | ID
    ;

ID: 
    IDENTIFIER
    ;

print_statement:
    PRINT value SEMICOLON
    ;

%%


void yyerror(const char* s) {
    fprintf(stderr, "%s\n", s);
}

int main() {
    yyparse();
    return 0;
}