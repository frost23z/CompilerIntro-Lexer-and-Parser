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
%token <char_value> CHARLIT
%token <str_value> IDENTIFIER
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
            root = create_node("Program");
        }
        root->no_of_children = 1;
        root->child = (ASTNode**)malloc(root->no_of_children * sizeof(ASTNode*));
        root->child[0] = $1;
        $$ = root;
    }
    | /* empty */
    {
        $$ = create_node("Empty_Program");
    }
    ;

statements:
    statements statement
    {
        $$ = create_node("Statements");
        $$->no_of_children = 2;
        $$->child = (ASTNode**)malloc($$->no_of_children * sizeof(ASTNode*));
        $$->child[0] = $1;
        $$->child[1] = $2;
    }
    | statement
    {
        $$ = create_node("Statements");
        $$->no_of_children = 1;
        $$->child = (ASTNode**)malloc($$->no_of_children * sizeof(ASTNode*));
        $$->child[0] = $1;
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
        ASTNode* id = create_node("ID");
        id->str_value = $1;
        ASTNode* type = $2;
        $$ = create_node("Variable_Declaration");
        $$->no_of_children = 2;
        $$->child = (ASTNode**)malloc($$->no_of_children * sizeof(ASTNode*));
        $$->child[0] = id;
        $$->child[1] = type;
    }
    ;

variable_type:
    INT
    {
        $$ = create_node("Type");
        $$->str_value = "int";
    }
    | CHAR
    {
        $$ = create_node("Type");
        $$->str_value = "char";
    }
    | FLOAT
    {
        $$ = create_node("Type");
        $$->str_value = "float";
    }
    ;

variable_initialization:
    IDENTIFIER ASSIGN value SEMICOLON
    {
        ASTNode* id = create_node("ID");
        id->str_value = $1;
        ASTNode* assignment = create_node("ASSIGN");
        ASTNode* val = $3;
        $$ = create_node("VariableInitialization");
        $$->no_of_children = 2;
        $$->child = (ASTNode**)malloc($$->no_of_children * sizeof(ASTNode*));
        $$->child[0] = id;
        $$->child[1] = assignment;
        assignment->no_of_children = 1;
        assignment->child = (ASTNode**)malloc(assignment->no_of_children * sizeof(ASTNode*));
        assignment->child[0] = val;
    }
    ;

value:
    INUM
    {
        $$ = create_node("IntegerLiteral");
        $$->inum_value = $1;
    }
    | FNUM
    {
        $$ = create_node("FloatLiteral");
        $$->fnum_value = $1;
    }
    | CHARLIT
    {
        $$ = create_node("CharacterLiteral");
        $$->char_value = $1;
    }
    | expression
    ;

expression:
    expression PLUS expression
    {
        $$ = create_node("PLUS");
        $$->no_of_children = 2;
        $$->child = (ASTNode**)malloc($$->no_of_children * sizeof(ASTNode*));
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | expression MINUS expression
    {
        $$ = create_node("MINUS");
        $$->no_of_children = 2;
        $$->child = (ASTNode**)malloc($$->no_of_children * sizeof(ASTNode*));
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | ID
    ;

ID: 
    IDENTIFIER
    {
        $$ = create_node("ID");
        $$->str_value = $1;
    }
    ;

print_statement:
    PRINT value SEMICOLON
    {
        ASTNode* print = create_node("PrintStatement");
        $$ = create_node("Print");
        $$->no_of_children = 2;
        $$->child = (ASTNode**)malloc($$->no_of_children * sizeof(ASTNode*));
        $$->child[0] = print;
        $$->child[1] = $2;
    }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "%s\n", s);
}

int main() {
    yyparse();
    print_ast(root);
    //free_ast(root);
    return 0;
}