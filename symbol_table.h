#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include "uthash.h"
#include <stdbool.h>

struct SymbolEntry
{
    char *name;
    int lineno;
    UT_hash_handle hh;
};

void init_symbol_table();

void insert_symbol(const char *name, int lineno);

bool symbol_exists(const char *name);

int get_symbol_line(const char *name);

void print_symbol_table();

void free_symbol_table();

#endif /* SYMBOL_TABLE_H */