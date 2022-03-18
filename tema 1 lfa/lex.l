
%{ 
    #include<string.h>
    int state = 0;
    int count = 0;
    char* fromState;
    char* varName;
    char** varContent;
    char * update;
    int stari_finale;
    int varContentindex;
    char* alfabetGramatica;
%} 

%%

"%"(.)* // comentariu single line
"/*"(.|\n)*"*/" // comentariu multiple line

variable {
    if(state == 1)
        state = 88;
    if(state == 0)
        state = 99;
}

alphabet {
    if (state == 2)
        state = 3;
    if (state == -1)
        state = -2;
}

stack_alphabet {state = 4;}

states {state = 5;}

final_states {state = 6; stari_finale = 1;}

initial_state {state = 7;}


[a-zA-Z0-9]+/" ::= Grammar" {
    printf("Numele gramaticii: %s\n", yytext);
    state = -1;
}

[a-zA-Z0-9]+/" ::= PushDownAutomata" {
    printf("Numele automatului: %s\n", yytext);
    state = 1;
    stari_finale = 0;
}

[a-zA-Z0-9]+/" -> (" {
    if(state == 2) {
        fromState = (char*) malloc(sizeof(char)*strlen(yytext));
        for(int i = 0; i < strlen(yytext) ; i++) {
            fromState[i] = yytext[i];
        }
        fromState[strlen(yytext)] = 0;
        state = 8;
    }
    if(stari_finale == 0) {
        printf("Stari finale: {}\n");
        stari_finale = 2; //finished
    }
}


[a-zA-Z0-9]+", "[a-zA-Z0-9]+ {
    if(state == 8) {
        printf("m(%s, %s) = ", fromState, yytext);
        state = 9;
    }
}

":: = {"

([a-zA-Z0-9]*&?[a-zA-Z0-9]+) { 
    if(state == 1) {
        printf("Tipul automatului: Automat Cu stiva\n");
        state = 2;
    }
    if(state == 5) {
        count++;
        printf("%d\n", count);
    }
    if(state == 7){
        printf("Stare initiala: %s\n", yytext);
        state = 2;
    }

    if(state == 10) {
        printf("(%s, %s)\n", yytext, update);
        free(update);
        state = 8;
    }

    if(state == 9) {
        update = (char*) malloc(sizeof(char)*strlen(yytext));
        for(int i = 0; i < strlen(yytext) ; i++) {
            update[i] = yytext[i];
        }
        state = 10;
    }

    if(state == 88) {
        varName = (char *) malloc(sizeof(char)* strlen(yytext));
        for(int i = 0; i < strlen(yytext); i++){
            varName[i] = yytext[i];
        }
        varContent = (char **) malloc(sizeof(char*) * 64);
        varContentindex = 0;
        state = 89;
    }
    if(state == 89) {
        varContent[varContentindex] = (char*)malloc(sizeof(char) * strlen(yytext));
        for(int i = 0 ; i < strlen(yytext); i++) {
            varContent[varContentindex][i] = yytext[i];
        }
        varContent[varContentindex][strlen(yytext)] = 0;
        varContentindex++;
    }
}

"{"[a-zA-Z0-9, ]*"}" {
    if(state == -2) {
        alfabetGramatica = malloc(sizeof(char)* strlen(yytext));
        for(int i = 0; i < strlen(yytext); i++) {
            alfabetGramatica[i] = yytext[i];
        }
        alfabetGramatica[strlen(yytext)] = 0;
        state = -3;
    }

    if(state == 3) {
        printf("Alfabetul de intrare: %s\n", yytext);
    }

    if(state == 6) {
        if(stari_finale == 1)
            printf("Stari finale: %s\n", yytext);
    }

    if(state == 5) { // atat se poate
        for(int i = 0; i < strlen(yytext); i ++){
            if(yytext[i] == ',')
                count++;
        }
        printf("Numarul de stari: %d\n", count + 1);
        count = 0; 
        state = 2;
    }
}

"} ;" {
    state = 1;
}

") ;;" {
    if(state == -3) {
        printf("Alfabetul gramaticii: %s\n", alfabetGramatica);
    }
    free(alfabetGramatica);
    state = 0;
}

") ;" {
    state = 2;
    free(fromState);
}


(.|\n) 

%% 

int yywrap(){} 
int main(int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    yylex();
    fclose(yyin); 
return 0; 
} 