#include "ast.h"

ASTNode *create_node(const char *node_name)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->node_name = strdup(node_name);
    node->child = NULL;
    node->inum_value = 0;
    node->fnum_value = 0.0;
    node->char_value = '\0';
    node->str_value = NULL;
    node->no_of_children = 0;
    return node;
}

ASTNode *create_child_node(const char *node_name, ASTNode *node)
{
    if (node->child == NULL)
    {
        node->child = (ASTNode *)malloc(sizeof(ASTNode));
    }
    else
    {
        node->child = (ASTNode *)realloc(node->child, (node->no_of_children + 1) * sizeof(ASTNode));
    }

    node->child[node->no_of_children] = *create_node(node_name);
    node->no_of_children++;

    return &node->child[node->no_of_children - 1];
}

void print_ast_node(ASTNode *node, int indent)
{
    if (node == NULL)
    {
        return;
    }

    for (int i = 0; i < indent; i++)
    {
        printf("  "); // Use two spaces for each level of indentation
    }

    printf("%s", node->node_name);

    if (strcmp(node->node_name, "inum") == 0)
    {
        printf(": %d", node->inum_value);
    }
    else if (strcmp(node->node_name, "fnum") == 0)
    {
        printf(": %f", node->fnum_value);
    }
    else if (strcmp(node->node_name, "charlit") == 0)
    {
        printf(": %c", node->char_value);
    }

    printf("\n");

    for (int i = 0; i < node->no_of_children; i++)
    {
        print_ast_node(&node->child[i], indent + 1);
    }
}

void print_ast(ASTNode *root)
{
    if (root == NULL)
    {
        printf("AST is empty.\n");
        return;
    }

    printf("Abstract Syntax Tree:\n");
    print_ast_node(root, 0);
}

void free_ast(ASTNode *node)
{
    if (node == NULL)
    {
        return;
    }

    for (int i = 0; i < node->no_of_children; i++)
    {
        free_ast(&node->child[i]);
    }

    free(node->node_name);
    free(node->child);
    free(node);
}
