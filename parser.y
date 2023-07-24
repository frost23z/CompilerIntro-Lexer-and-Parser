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

%type <node_ptr> program statements statement variable_declaration variable_type variable_initialization value expression ID print_statement

%left PLUS MINUS

%start program

%%

program:
    statements
    {
        if (root == NULL)
        {
            root = create_node("program");
        }
        root->no_of_children = 1;
        root->child = (ASTNode *)malloc(root->no_of_children * sizeof(ASTNode));
        root->child[0] = *$1;
        $$ = root;
    }
    | /* empty */
    {
        $$ = create_node("empty_program");
    }
    ;

statements:
    statements statement
    {
        $$ = create_node("statements");
        $$->no_of_children = 2;
        $$->child = (ASTNode *)malloc($$->no_of_children * sizeof(ASTNode));
        $$->child[0] = *$1;
        $$->child[1] = *$2;
    }
    | statement
    {
        $$ = create_node("statements");
        $$->no_of_children = 1;
        $$->child = (ASTNode *)malloc($$->no_of_children * sizeof(ASTNode));
        $$->child[0] = *$1;
    }
    ;


statement:
    variable_declaration
    | variable_initialization
    | print_statement
    ;

variable_declaration:
    IDENTIFIER variable_type SEMICOLON
    {
        ASTNode* id = create_child_node("ID", $1);
        ASTNode* type = $2;
        $$ = create_node("variable_declaration");
        $$->no_of_children = 1;
        $$->child = (ASTNode *)malloc($$->no_of_children * sizeof(ASTNode));
        $$->child[$$->no_of_children - 1] = *id;
        $$->child = (ASTNode *)realloc($$->child, ($$->no_of_children + 1) * sizeof(ASTNode));
        $$->child[$$->no_of_children] = *type;
        $$->no_of_children++;
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
        ASTNode* assignment = create_child_node("ASSIGN", $$);
        ASTNode* val = $3;
        $$ = create_node("variable_initialization");
        $$->no_of_children = 2;
        $$->child = (ASTNode *)malloc($$->no_of_children * sizeof(ASTNode));
        $$->child[$$->no_of_children - 2] = *id;
        $$->child[$$->no_of_children - 1] = *assignment;
        $$->child = (ASTNode *)realloc($$->child, ($$->no_of_children + 1) * sizeof(ASTNode));
        $$->child[$$->no_of_children] = *val;
        $$->no_of_children++;
    }
    ;


value:
    INUM
    {
        $$ = create_node("INUM");
        $$->inum_value = $1;
    }
    | FNUM
    {
        $$ = create_node("FNUM");
        $$->fnum_value = $1;
    }
    | CHARLIT
    {
        $$ = create_node("CHARLIT");
        $$->char_value = $1[0];
    }
    | expression
    ;

expression:
    expression PLUS expression
    {
        $$ = create_node("PLUS");
        $$->no_of_children = 2;
        $$->child = (ASTNode *)malloc($$->no_of_children * sizeof(ASTNode));
        $$->child[0] = *$1;
        $$->child[1] = *$3;
    }
    | expression MINUS expression
    {
        $$ = create_node("MINUS");
        $$->no_of_children = 2;
        $$->child = (ASTNode *)malloc($$->no_of_children * sizeof(ASTNode));
        $$->child[0] = *$1;
        $$->child[1] = *$3;
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
    print_ast(root);
    free_ast(root);
    return 0;
}
