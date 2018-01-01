/**
 * Define a grammar called Hello
 */
grammar mana;

/*
 * Parser rules
 */

program: 
	import_block? declarations?;

// Import Statements
import_block: 
                'import' '(' import_statements? ')'
            ;

import_statements:
                     (import_statement ',')* import_statement
                 ;

import_statement: 
            import_sequence ('{' import_sequence_list '}')?
	;
               
import_sequence: 
	(ID '.')* ID;

import_sequence_list: 
	(import_sequence ',')* import_sequence;

/*
 * Declarations
 */
declarations: 
	(
		module_decl 
		| fn_decl 
		| type_decl		
	)+
	;

/*
 * Module declaration
 */
module_decl: 
	'module' ID '{'
		(
			module_decl 
			| fn_decl 
			| type_decl
		)*
	'}';

fn_param_list:
	(fn_param ',')* fn_param
	;

fn_param:
	'mut'? ID ':' type_
	; 

// Types

type_:
	namespace ('<' type_list '>')?
    |   basic_type
    |   type_ '[' ']'
	;

type_list:
             (type_ ',')* type_
         ;

basic_type:
              'char'
          |   'bool'
          |   'u8'
          |   'i8'
          |   'u16'
          |   'i16'
          |   'u32'
          |   'i32'
          |   'u64'
          |   'i64'
          |   'f32'
          |   'f64'
          |   'byte'
          ;

type_decl: 
	class_decl 
	| interface_decl
	| enum_decl
	| typedef_decl
	;

enum_decl:
             'local'? 'enum' '{' enum_list '}'
         ;

enum_list:
             (enum_elt ',') enum_elt
         ;

enum_elt:
            ID
        ;

typedef_decl:
                'local'? 'type' ID '=' type_
            ;

class_decl:
              'class' ID templates? class_extends? '{' class_definition '}'
          ;

class_extends:
                 'extends' namespace
             ;

class_definition:
                    annotations?
                    (
                        class_method
                    |   class_attribute
                    |   static_method
                    |   static_class_attribute
                    |   class_operator
                    )*
                ;

class_method:
            'local' ? fn_decl
            ;

class_operator:
                  'local'? op_decl
              ;

static_method:
                 'static' class_method
             ;

class_attribute:
                   'let' 'local'? 'mut'? id_list (':' type_)? ('=' expression_list)
               ;

static_class_attribute:
                          'local'? class_attribute
                      ;

interface_decl:
                  'interface' ID templates? class_extends? '{' interface_definition '}'
              ;

interface_definition:
                        (
                        interface_method
                    |   interface_operator
                        )+
                    ;

interface_method:
                    'local'? fn_header
                ;

interface_operator:
                      'local'? op_header
              ;


fn_header:
             'fn' ID '(' params? optional_params? ')' ('->' type_)
         ;
op_header:             
             'fn' OVERRIDABLE_OP '(' params? optional_params? ')' ('->' type_)
         ;

fn_decl:
           fn_header block
       |   fn_header '=' expression
       ;

op_decl:
           op_header block
       |   op_header '=' expression
       ;

var_decl:
            'let' 'mut'? id_list (':' type_)? ('=' expression_list)
        ;

block:
         '{' statement* '}'
     ;

statement:
             (
                 block
             |   var_decl
             |   repeat_stmt
             |   while_stmt
             |   for_stmt
             |   foreach_stmt
             |   expression
             |   return_stmt
             |   break_stmt
             |   skip_stmt
             |   if_stmt
             |   match_stmt
             )
;

repeat_stmt:
               'repeat' block 'while' expression
           ;

while_stmt:
              'while' expression block
          ;

for_stmt:
            'for' expression_list ';' expression ';' expression_list block
        ;

foreach_stmt:
                'foreach' 'mut' ID (':' type_) 'in' expression block
            ;

return_stmt:
               'return' expression?
           ;

break_stmt:
              'break'
          ;

skip_stmt:
                 'skip'
             ;

if_stmt:
           'if' expression block ('else' 'if' expression block)* ('else' block)?
       ;

match_stmt:
              'match' expression '{' match_elt+ match_else? '}'
          ;

match_elt:
              expression '=>' statement
          ;

match_else:
              'else' '=>' statement
          ;

annotations:
               annotation+
           ;

annotation:
              '@' ID ( '(' optional_params ')')
          ;

templates:
            '<' id_list '>'
         ;

params:
          (param ',')* param
      ;

param:
         'mut' ID ':' type_
     ;

optional_params:
                   (optional_param ',')* optional_param
               ;

optional_param:
                  param '=' expression
              ;

expression_list:   
                  (expression ',')* expression
               ;

expression: 
                  var_decl 'in' expression
              |   'match' expression '{' (expression '=>' expression)+ 'else' '=>' expression'}'
              |   op_assign
          ;

op_assign:
             op_or ('='|'+='|'-='|'*='|'/='|'%='|'^='|'&='|'|='|'>>='|'<<=') op_assign
         |   op_or
         ;

op_or:
         op_or '||' op_and
     |   op_and
     ;

op_and:
          op_and '&&' op_bin_or
      |   op_bin_or
      ;

op_bin_or:
             op_bin_or '|' op_bin_xor
         |   op_bin_xor
         ;

op_bin_xor:
              op_bin_xor '^' op_bin_and
          |   op_bin_and
          ;

op_bin_and:
              op_bin_and '&' op_eq
          |   op_eq
          ;

op_eq:
         op_eq ( '==' | '!=' ) op_compare
     |   op_compare
     ;

op_compare:
              op_compare ( '<' | '>' | '<=' | '>=' | 'is' ) op_shift
          |   op_shift
          ;

op_shift:
            op_shift ( '<<' | '>>' ) op_add
        |   op_add
        ;

op_add:
          op_add ( '+' | '-' ) op_mult
      |   op_mult
      ;

op_mult:
           op_mult ( '*' | '/' | '%' ) op_unary
       |   op_unary
       ;

op_unary:
            '!' op_unary
        |   '~' op_unary
        |   '+' op_unary
        |   '-' op_unary
        |   '++' op_unary
        |   op_pointer '++'
        |   op_pointer '--'
        |   op_unary 'as' type_
        |   'sizeof' op_pointer
        |   op_pointer
        ;

op_pointer:
              op_pointer '.' value
          |   op_pointer '[' expression_list ']' 
          |   op_pointer  '(' fn_params_expressions? ')'
          |   value
          ;

fn_params_expressions:
                 (fn_param_expression ',')* fn_param_expression
                     ;

fn_param_expression:
                       expression
                   |   ID ':' expression
                   ;

id_list:
           ID ',' id_list
       |   ID
       ;

namespace:
             ID '.' namespace
         |   ID
         ;               


value:
         ID
     |   DECIMAL_LITERAL
     |   HEX_LITERAL
     |   OCT_LITERAL
     |   BINARY_LITERAL
     |   FLOAT_LITERAL
     |   HEX_FLOAT_LITERAL
     |   STRING_LITERAL
     |   CHAR_LITERAL
     |   BOOLEAN
     |   OVERRIDABLE_OP
     |   namespace
     |   lambda_expression
     |   array_comprehension
     ;

lambda_expression:
                     'fn' '(' params? ')' ('->' type_)? (('=' expression ) | block)
                 ;

array_comprehension:
                       '[' 'for' ID (':' type_)? 'in' expression ('if' expression)? '=>' expression ']'
                   ;
         
       
/*
 * Lexer rules
 */

ID : [A-Za-z_]+[A-Za-z0-9_]*;
BOOLEAN: 'true' | 'false';
DECIMAL_LITERAL: ('0' | [1-9] (Digits? | '_'+ Digits)) [lL]?;
HEX_LITERAL: '0' [xX] [0-9a-fA-F] ([0-9a-fA-F_]* [0-9a-fA-F])? [lL]?;
OCT_LITERAL: '0' '_'* [0-7] ([0-7_]* [0-7])? [lL]?;
BINARY_LITERAL: '0' [bB] [01] ([01_]* [01])? [lL]?;
FLOAT_LITERAL:      (Digits '.' Digits? | '.' Digits) ExponentPart? [fFdD]?
             |       Digits (ExponentPart [fFdD]? | [fFdD])
             ;

HEX_FLOAT_LITERAL:  '0' [xX] (HexDigits '.'? | HexDigits? '.' HexDigits) [pP] [+-]? Digits [fFdD]?;


CHAR_LITERAL:       '\'' (~['\\\r\n] | EscapeSequence) '\'';

STRING_LITERAL: '"' (~["\\\r\n] | EscapeSequence)* '"';

fragment ExponentPart
    : [eE] [+-]? Digits
    ;

fragment EscapeSequence
    : '\\' [btnfr"'\\]
    | '\\' ([0-3]? [0-7])? [0-7]
    | '\\' 'u'+ HexDigit HexDigit HexDigit HexDigit
    ;
fragment HexDigits
    : HexDigit ((HexDigit | '_')* HexDigit)?
    ;
fragment HexDigit
    : [0-9a-fA-F]
    ;
fragment Digits
    : [0-9] ([0-9_]* [0-9])?
    ;
fragment LetterOrDigit
    : Letter
    | [0-9]
    ;
fragment Letter
    : [a-zA-Z$_] // these are the "java letters" below 0x7F
    | ~[\u0000-\u007F\uD800-\uDBFF] // covers all characters above 0x7F which are not a surrogate
    | [\uD800-\uDBFF] [\uDC00-\uDFFF] // covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
    ;


OVERRIDABLE_OP:
                  '+'
              |   '-'
              |   '*'
              |   '/'
              |   '%'
              |   '^'
              |   '&'
              |   '|'
              |   '~'
              |   '!'
              |   '='
              |   '>'
              |   '<'
              |   '+='
              |   '-='
              |   '*='
              |   '/='
              |   '%='
              |   '^='
              |   '&='
              |   '|='
              |   '<<'
              |   '>>'
              |   '<<='
              |   '>>='
              |   '=='
              |   '!='
              |   '<='
              |   '>='
              |   '&&'
              |   '||'
              |   '++'
              |   '--'
              |   '()'
              |   '[]'
              ;
                  

WS:                 [ \t\r\n\u000C]+ -> channel(HIDDEN);
COMMENT:            '/*' .*? '*/'    -> channel(HIDDEN);
LINE_COMMENT:       '//' ~[\r\n]*    -> channel(HIDDEN);
