grammar Mana;

Identifier: [_a-zA-Z][_a-zA-Z0-9]*;
fragment Integer: [1-9]+;

//
// Whitespace and comments
//

WS  :  [ \t\r\n\u000C]+ -> skip
    ;

COMMENT
    :   '/*' .*? '*/' -> skip
    ;

LINE_COMMENT
    :   '//' ~[\r\n]* -> skip
;

program 
	:	importStatement? declarations?;

//
// Import Statements
//
importStatement
	:	'import' '(' importElt+ ')'
	;

importElt
	:	Identifier ('.' Identifier)* ('.' '*' | '[' subImports ']')?
	;

subImports
	:	subImport (',' subImport)*
	;

subImport
	:	Identifier ('.' Identifier)*
	;

//
// Declarations
//

declarations: declaration+;

declaration
	:	classDeclaration
	|	interfaceDeclaration
	//|	algebraicTypeDeclaration
	//|	fnDeclaration
	;


//
//  Classes and Interfaces
//

classDeclaration
	:	'class' Identifier genericTemplates? classImplements? classBody
	;

interfaceDeclaration
	:	'interface' Identifier genericTemplates? interfaceExtends? interfaceBody
	;

classImplements
	:	'implements' superTypes
	;

interfaceExtends
	:	'extends' superTypes
	;

superTypes
	:	superType (',' superType)*
	;

superType
	:	interfaceOrClassName templateIdOrTypeList?
	;

classBody
	:	'{' '}'
	;

interfaceBody
	:	'{' '}'
	;


//
// Types and templates
//
BasicType
	:	'u8'
	|	'i8'
	|	'u16'
	|	'i16'
	|	'u32'
	|	'i32'
	|	'u64'
	|	'i64'
	|	'f32'
	|	'f64'
	|	'char'
	|	'byte'
	|	'bool'
	;

interfaceOrClassName
	:	Identifier ('.' Identifier)*
	;

templateId
	:	Identifier
	;

genericTemplates
	:	'<'  templateId(',' templateId)* '>'
	;

templateIdOrTypeList
	:	'<' templateIdOrType (',' templateIdOrType)* '>'
	;

templateIdOrType
	:	templateId
	|	type
	;

type
	:	BasicType
	|	interfaceOrClassOrEnumName
	|	genericType
	|	type ('['']')+
	;

genericType
	:	interfaceOrClassOrEnumName '<' typeList '>'
	;

typeList
	:	type (',' type)*
	;

interfaceOrClassOrEnumName
	:	Identifier ('.' Identifier)*
	;
