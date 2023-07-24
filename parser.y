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
%token <str_value> CHARLIT
%token <node_ptr> IDENTIFIER
%token INT CHAR FLOAT PRINT ASSIGN PLUS MINUS SEMICOLON

%type <node_ptr> program statements variable_declaration variable_type variable_initialization value expression ID print_statement

%left PLUS MINUS

%start program

%%

program:
    program statements
    {
        if (root == NULL)
        {
            root = create_node("program");
        }
        root->child = $2;
        $$ = root;
    }
    | /* empty */
    {
        $$ = create_node("empty_program");
    }
    ;

statements:
    variable_declaration
    | variable_initialization
    | print_statement
    ;

variable_declaration:
    IDENTIFIER variable_type SEMICOLON
    {
        ASTNode* id = create_child_node("ID", $1);
        ASTNode* type = create_child_node("type", $2);
        $$ = create_node("variable_declaration");
    }
    ;

variable_type:
    INT
    {
        $$ = create_node("int");
    }
    | CHAR
    {
        $$ = create_node("char");
    }
    | FLOAT
    {
        $$ = create_node("float");
    }
    ;

variable_initialization:
    IDENTIFIER ASSIGN value SEMICOLON
    {
        ASTNode* id = create_child_node("ID", $1);
        ASTNode* value = create_child_node("value", $3);
        $$ = create_node("variable_initialization");
    }
    ;

value:
    INUM
    {
        $$ = create_child_node("INUM", $$);
        $$->inum_value = $1;
    }
    | FNUM
    {
        $$ = create_child_node("FNUM", $$);
        $$->fnum_value = $1;
    }
    | CHARLIT
    {
        $$ = create_child_node("CHARLIT", $$);
        $$->char_value = $1[0];
    }
    | expression
    ;

expression:
    expression PLUS expression
    {
        $$ = create_node("PLUS");
        $$->child = $1;
        $1 = create_child_node("PLUS", $$);
        $1->child = $3;
    }
    | expression MINUS expression
    {
        $$ = create_node("MINUS");
        $$->child = $1;
        $1 = create_child_node("MINUS", $$);
        $1->child = $3;
    }
    | ID
    {
        $$ = create_child_node("ID", $1);
    }
    ;

ID: 
    IDENTIFIER
    ;

print_statement:
    PRINT value SEMICOLON
    {
        $$ = create_node("print_statement");
        $$->child = $2;
    }
    ;

%%


void yyerror(const char* s) {
    fprintf(stderr, "%s\n", s);
}

int main() {
    yyparse();
    print_ast(root); // Print the constructed AST
    free_ast(root); // Free the memory used by the AST
    return 0;
}
