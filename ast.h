#ifndef AST_H
#define AST_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

struct ASTNode
{
    char *node_name;
    int inum_value;
    float fnum_value;
    char char_value;
    char *str_value;
    struct ASTNode **child;
    int no_of_children;
};

typedef struct ASTNode ASTNode;

ASTNode *create_node(const char *node_name);
ASTNode *create_child_node(const char *node_name, ASTNode *node);
void print_ast_node(ASTNode *node, int indent);
void print_ast(ASTNode *root);
void free_ast(ASTNode *node);

#endif /* AST_H */