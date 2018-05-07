# https://github.com/durkiewicz/elm-plugin/blob/master/src/main/java/org/elmlang/intellijplugin/Elm.bnf#L31
# https://github.com/durkiewicz/elm-plugin/blob/90cd837e452b20bf06d09cc4f70bd729e549a6ff/src/main/java/org/elmlang/intellijplugin/Elm.flex

@{%
const moo = require("moo");

const lexer = moo.compile({

  KEYWORD: 
    [ "if", "then", "else"
    , "case", "of"
    , "let", "in"
    , "type"
    , "module", "where"
    , "import", "exposing"
    , "as"
    , "port", "effect"
    , "infixl", "infix", "infixr"
    ],
  UPPER_CASE_PATH_OR_ID: /(?:[A-Z][a-z0-9_]*)+/,
  LOWER_CASE_PATH_OR_ID: /(?:[a-z][a-z0-9_]*)+/,
  MIXED_CASE_PATH_OR_ID: /(?:[a-zA-Z][a-z0-9_]*)+/,
  L_PAREN: '(',
  R_PAREN: ')',
  L_BRACE: '{',
  R_BRACE: '}',
  L_BRACKET: '[',
  R_BRACKET: ']',
  PIPE: '|',
  COMMA: ',',
  EQ: '=',
  DOUBLE_DOT: '..',
  OPERATOR: /[^\(\)\s]+/,    // OPERATOR=("!"|"$"|"^"|"|"|"*"|"/"|"?"|"+"|"~"|"."|-|=|@|#|%|&|<|>|:|€|¥|¢|£|¤)+
  __: { match: /\s+/, lineBreaks: true }
});
%}

@lexer lexer

@{% function nuller() { return null; } %}


main -> _ moduleDeclaration _

moduleDeclaration -> ( "effect" | "port"):? _ "module" _ UPPER_CASE_PATH _ ( "where" _ record ):? _ "exposing" _ exposedList

# ---- exposing  ----
exposedList -> L_PAREN _ ( DOUBLE_DOT | exposedListItem:+ ) _ R_PAREN

exposedListItem -> ( LOWER_CASE_ID | exposedUnion | operatorAsFunction) _ COMMA:? _

exposedUnion -> UPPER_CASE_ID exposedUnionList:?

exposedUnionList -> L_PAREN _ ( DOUBLE_DOT | exposedUnionListItem:+ ) _ R_PAREN

exposedUnionListItem -> UPPER_CASE_ID _ COMMA:? _
# --- //exposing ---

# ---- record ----
record -> L_BRACE _ (recordBase:? _ recordListItem:+ _):? R_BRACE

recordBase -> LOWER_CASE_ID _ PIPE

recordListItem -> LOWER_CASE_ID _ EQ _ expression
# --- //record ---


# ---- expression ----
expression -> operandsList _ (operator _ operandsList _):* 

operandsList -> MINUS:? operand:+

operator ->
    OPERATOR
    | LIST_CONSTRUCTOR
    | MINUS
    | DOT

operand ->
      literal
    | referenced_value
    | field_access
    | operator_as_function
    | parenthesed_expression
    | tuple_constructor
    | tuple
    | list
    | record
    | if_else
    | case_of
    | let_in
    | anonymous_function
# --- //expression ---



#  ---- expression parts ----
literal ->
      STRING_LITERAL
    | NUMBER_LITERAL
    | CHAR_LITERAL

referenced_value ->
      LOWER_CASE_PATH
    | UPPER_CASE_PATH
    | MIXED_CASE_PATH
#  ---- expression parts ----



# ---- other ----
operatorAsFunction -> L_PAREN OPERATOR R_PAREN

# --- //other ---






# ---- terminals  ----
UPPER_CASE_PATH -> %UPPER_CASE_PATH_OR_ID
LOWER_CASE_PATH -> %LOWER_CASE_PATH_OR_ID
MIXED_CASE_PATH -> %MIXED_CASE_PATH_OR_ID
UPPER_CASE_ID -> %UPPER_CASE_PATH_OR_ID
LOWER_CASE_ID -> %LOWER_CASE_PATH_OR_ID
MIXED_CASE_ID -> %MIXED_CASE_PATH_OR_ID
COMMA -> %COMMA
L_PAREN -> %L_PAREN
R_PAREN -> %R_PAREN
L_BRACE -> %L_BRACE
R_BRACE -> %R_BRACE
L_BRACKET -> %L_BRACKET
R_BRACKET -> %R_BRACKET
PIPE -> %PIPE
COMMA -> %COMMA
EQ -> %EQ
DOUBLE_DOT -> %DOUBLE_DOT
OPERATOR -> %OPERATOR
__ -> %__      {% nuller %}
_ -> %__:?     {% nuller %}
# ---- //terminals ----

# NOTE: the last char in this file has to be a newline 
# (see https://github.com/kach/nearley/issues/349)
