#include "ast.h"

ASTNode *create_node(const char *node_name)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (node == NULL)
    {
        fprintf(stderr, "Memory allocation failed\n");
        exit(EXIT_FAILURE); /* Handle memory allocation failure */
    }
    node->node_name = strdup(node_name);
    node->child = NULL;
    node->inum_value = 0;
    node->fnum_value = 0.0;
    node->char_value = '\0';
    node->str_value = NULL;
    node->no_of_children = 0;
    return node;
}

ASTNode *create_child_node(const char *node_name, ASTNode *parent)
{
    ASTNode *node = create_node(node_name);
    parent->no_of_children++;
    parent->child = (ASTNode **)realloc(parent->child, parent->no_of_children * sizeof(ASTNode *));
    parent->child[parent->no_of_children - 1] = node;
    return node;
}

void print_ast_node(ASTNode *node, int indent)
{
    if (node == NULL)
    {
        return;
    }

    for (int i = 0; i < indent; i++)
    {
        printf("|   ");
    }

    printf("+-- %s", node->node_name);

    if (strcmp(node->node_name, "ID") == 0 || strcmp(node->node_name, "Type") == 0)
    {
        printf(": %s", node->str_value);
    }
    else if (strcmp(node->node_name, "IntegerLiteral") == 0)
    {
        printf(": %d", node->inum_value);
    }
    else if (strcmp(node->node_name, "FloatLiteral") == 0)
    {
        printf(": %f", node->fnum_value);
    }
    else if (strcmp(node->node_name, "CharacterLiteral") == 0)
    {
        printf(": %c", node->char_value);
    }

    printf("\n");

    for (int i = 0; i < node->no_of_children; i++)
    {
        print_ast_node(node->child[i], indent + 1);
    }
}

void print_ast(ASTNode *root)
{
    if (root == NULL)
    {
        printf("AST is empty.\n");
        return;
    }
    if (strcmp(root->node_name, "Empty_Program") == 0)
    {
        printf("Empty Program: No Statements\n");
        return;
    }
    printf("\t\t\tAbstract Syntax Tree:\n\n");
    print_ast_node(root, 0);
}

void free_ast(ASTNode *node)
{
    if (node == NULL)
    {
        return;
    }

    // Free child nodes
    for (int i = 0; i < node->no_of_children; i++)
    {
        free_ast(node->child[i]);
    }

    // Check if str_value is not NULL before freeing
    if (node->str_value != NULL)
    {
        free(node->str_value);
    }

    // Free other allocated memory
    free(node->node_name);

    // Finally, free the node itself
    free(node);
}
