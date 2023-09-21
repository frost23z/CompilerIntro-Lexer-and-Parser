%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include <setjmp.h>     /* Include the setjmp header for longjmp and jmp_buf */
    #include "symbol_table.h"
    #include "ast.h"

    /* Declare error-handling function */
    int yyerror(const char* s);

    /* Declare a jump buffer for error handling */
    jmp_buf error_buf;

    /* Declare external lexer and line number variables */
    extern int yylex(void);
    extern int yylineno;
    
    /* Initialize the root of the AST as NULL */
    struct ASTNode* root = NULL;
%}

%union
{
    int inum_value;                  /* Integer value */
    float fnum_value;                /* Float value */
    char char_value;                 /* Character value */
    char* str_value;                 /* String (identifier) value */
    struct ASTNode* node_ptr;        /* Pointer to an AST node */
}

/* Define the token types */
%token <inum_value> INUM             /* Integer literal */
%token <fnum_value> FNUM             /* Float literal */
%token <char_value> CHARLIT          /* Character literal */
%token <str_value> IDENTIFIER        /* Identifier token */
%token INT CHAR FLOAT PRINT          /* Keywords and types */
%token ASSIGN PLUS MINUS SEMICOLON   /* Operators and punctuation */

%type <node_ptr> program statements statement variable_declaration variable_type variable_initialization value expression ID print_statement

/* Define the precedence of the operators */
%left PLUS MINUS

/* Define the start symbol */
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
        root = create_node("Empty_Program");
        $$ = root;
    }
    ;

statements:
    statement
    {
        $$ = create_node("Statements");
        $$->no_of_children = 1;
        $$->child = (ASTNode**)malloc($$->no_of_children * sizeof(ASTNode*));
        $$->child[0] = $1;
    }
    |
    statements statement
    {
        /* Create or update the "Statements" node and increment the number of children */
        if ($$) {
            $$->no_of_children++;
            $$->child = (ASTNode**)realloc($$->child, $$->no_of_children * sizeof(ASTNode*));
            $$->child[$$->no_of_children - 1] = $2; // Add the new statement as a child
        } else {
            /* If $$ is NULL, create a new "Statements" node */
            $$ = create_node("Statements");
            $$->no_of_children = 1;
            $$->child = (ASTNode**)malloc(sizeof(ASTNode*));
            $$->child[0] = $2; /* Add the first statement as a child */
        }
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

        /* Check if the variable is already declared in the symbol table */
        if (symbol_exists($1))
        {
            fprintf(stderr, "Error: variable '%s' declared in line:%d was already declared in line:%d\n", $1, yylineno, get_symbol_line($1));
            longjmp(error_buf, 1);
        }
        /* Insert the variable into the symbol table with a default value of 0 */
        insert_symbol($1, yylineno);
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

        /* Check if the variable is already declared in the symbol table */
        if (!symbol_exists($1))
        {
            fprintf(stderr, "Error: variable '%s' in line:%d was not declared\n", $1, yylineno);
            longjmp(error_buf, 1);
        }
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

int yyerror(const char* s)
{
    fprintf(stderr, "Error: %s in line:%d\n", s, yylineno);
    longjmp(error_buf, 1);  /* Perform a non-local jump back to the main function. */
}

int main()
{
    init_symbol_table();    /* Initialize the symbol table before parsing */
    if (setjmp(error_buf) == 0)
    {
        yyparse();          /* Continue parsing if no errors occurred. */
        print_ast(root);    /* Print the Abstract Syntax Tree */
        free_ast(root);     /* Free memory associated with the AST */
    }
    free_symbol_table();    /* Free the memory used by the symbol table after parsing */
    return 0;
}
