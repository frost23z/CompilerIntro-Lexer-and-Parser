#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

static struct SymbolEntry *symbol_table = NULL;

void init_symbol_table()
{
    symbol_table = NULL;
}

void insert_symbol(const char *name, int line)
{
    struct SymbolEntry *entry = (struct SymbolEntry *)malloc(sizeof(struct SymbolEntry));
    entry->name = strdup(name);
    entry->lineno = line;
    HASH_ADD_KEYPTR(hh, symbol_table, entry->name, strlen(entry->name), entry);
}

bool symbol_exists(const char *name)
{
    struct SymbolEntry *entry;
    HASH_FIND_STR(symbol_table, name, entry);
    return entry != NULL;
}

void print_symbol_table()
{
    struct SymbolEntry *entry;
    int i = 1;
    printf("Symbol Table:\n");
    for (entry = symbol_table; entry != NULL; entry = entry->hh.next)
    {
        printf("%d:\t'%s'\twas declared in line no: %d\n", i++, entry->name, entry->lineno);
    }
}

void free_symbol_table()
{
    struct SymbolEntry *entry, *tmp;
    HASH_ITER(hh, symbol_table, entry, tmp)
    {
        HASH_DEL(symbol_table, entry);
        free(entry->name);
        free(entry);
    }
}