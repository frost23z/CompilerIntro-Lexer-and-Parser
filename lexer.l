/***                   Definition section                     ***/
%option noyywrap
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    //#include "parser.tab.h"
    int line = 0;
%}


/***                     Rules section                       ***/
%%
[#][#][^#]*[#][#]                { /* Ignore the comment content                            */  printf("comment found!!"); }
[ \t]                            { /* ignore whitespace                                     */  printf(" ");               }
\n                               { /* line++;                                               */  printf("\n");              }
                        
"int"                            { /* return INT;                                           */  printf("INT");             }
"char"                           { /* return CHAR;                                          */  printf("CHAR");            }
"float"                          { /* return FLOAT;                                         */  printf("FLOAT");           }
"print"                          { /* return PRINT;                                         */  printf("PRINT");           }

[a-zA-Z_][a-zA-Z0-9_]*           { /* yylval.str_value = strdup(yytext); return IDENTIFIER; */  printf("IDENTIFIER");      }
[0-9]+                           { /* yylval.num_value = atoi(yytext); return INUM;         */  printf("INUM");            }
[0-9]+"."[0-9]+                  { /* yylval.num_value = atof(yytext); return FNUM;         */  printf("FNUM");            }
\'.\'                            { /* yylval.str_value = strdup(yytext); return CHARLIT;    */  printf("CHARLIT");         }
"="                              { /* return ASSIGN;                                        */  printf("ASSIGN");          }
"+"                              { /* return PLUS;                                          */  printf("PLUS");            }
"-"                              { /* return MINUS;                                         */  printf("MINUS");           }
"*"                              { /* return TIMES;                                         */  printf("TIMES");           }
"/"                              { /* return DIVIDE;                                        */  printf("DIVIDE");          }
"%"                              { /* return MOD;                                           */  printf("MOD");             }
"("                              { /* return LPAREN;                                        */  printf("LPAREN");          }
")"                              { /* return RPAREN;                                        */  printf("RPAREN");          }
";"                              { /* return SEMICOLON;                                     */  printf(" SEMICOLON");       }
","                              { /* return COMMA;                                         */  printf(" COMMA");           }
.                                { /* return ERROR;                                         */  printf(" ERROR");           }
%%


int main() {

    yyin = fopen("code.txt", "r+");
    yylex();
    return 0;
}
