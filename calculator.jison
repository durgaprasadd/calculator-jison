  
/* description: Parses end evaluates mathematical expressions. */

/* lexical grammar */
%lex
%%

\s+                   {/* skip whitespace */}
let               {return 'DECLARE'}
[A-z]+               {return 'VAR'}
[0-9]*("."[0-9]+)?\b {return 'NUMBER';}
"+"                  {return '+';}
"-"                  {return '-';}
"*"                  {return '*';}
"/"                  {return "/";}
"%"                  {return "%";}
"^"                  {return '^';}
"("                  {return '(';}
")"                  {return ')';}
"!"                  {return '!';}
"="                  {return '='}
";"                  {return ';'}
<<EOF>>              {return 'EOF';}

/lex

/* operator associations and precedence */

%left '+' '-'
%left '*' '/'
%left '^'
%right '!'
%right '%'
%left UMINUS


%start expressions

%% /* language grammar */

expressions
    : code EOF
        { 
            typeof console !== 'undefined' ? console.log(JSON.stringify($1)) : print($1);
            const declarations = {}

            const evaluateExpression = function(expression){
                if(!isNaN(expression)){
                    return expression;
                }

                if(!isNaN(declarations[expression])){
                    return declarations[expression];
                }
                switch(expression[0]){
                    case '+':
                        return evaluateExpression(expression[1]) + evaluateExpression(expression[2]);
                    case '-':
                        return evaluateExpression(expression[1]) - evaluateExpression(expression[2]);
                    case '*':
                        return evaluateExpression(expression[1]) * evaluateExpression(expression[2]);
                    case '/':
                        return evaluateExpression(expression[1]) / evaluateExpression(expression[2]);
                    case '^':
                        return Math.pow(evaluateExpression(expression[1]),evaluateExpression(expression[2]))
                    default:
                        return 0;
                }
            } 
            $1.forEach(
                statement => {
                    switch(statement[0]){
                        case '=':
                            declarations[statement[1]] = evaluateExpression(statement[2]);
                            break;
                        default:
                            console.log(evaluateExpression(statement))
                    }

                }) 
            return $1; }
    ;

code
    : STATEMENT ';' code
        {if(Array.isArray($3[0]))
            {$$ = [$1].concat($3)
            }
            else
            {$$ = [$1,$3]}
        }
    | STATEMENT ';'
        {$$ = $1}
    | e ';'
        {$$ = $1}
    | e
        {$$ = $1}
    ;


STATEMENT
    : DECLARE VAR '=' e
        {$$ = ['=',$2,$4]}
    | VAR '=' e
        {$$ = ['=',$1,$3]}
    ;

e
    : e '+' e
        {$$ = ['+',$1,$3];}
    | e '-' e
        {$$ = ['-',$1,$3];}
    | e '*' e
        {$$ = ['*',$1,$3];}
    | e '/' e
        {$$ = ['/',$1,$3];}
    | e '^' e
        {$$ = ['^',$1,$3];}
    | e '!'
        {$$ = ['!',$1]}
    | e '%'
        {$$ = ['/',$1,100]}
    | '-' e %prec UMINUS
        {$$ = -$2;}
    | '(' e ')'
        {$$ = $2;}
    | NUMBER
        {$$ = Number(yytext);}
    | E
        {$$ = Math.E;}
    | PI
        {$$ = Math.PI;}
    | VAR
        {$$ = $1}
    ;