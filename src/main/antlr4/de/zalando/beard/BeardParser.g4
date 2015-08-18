parser grammar BeardParser;

options {
  tokenVocab=BeardLexer;
}

@parser::header{
import de.zalando.beard.ast.*;
}

beard
locals [scala.collection.immutable.List<Statement> result]
      : statement*
      ;

statement
locals [Statement result]
         : structuredStatement
         | interpolation
         | text
         ;

structuredStatement
    : ifStatement
    | forStatement
    | renderStatement
    | blockStatement
    ;

blockStatement
locals [BlockStatement result]
    : blockInterpolation statement+ endBlockInterpolation
    ;

// {{ block header }}
blockInterpolation
    : LL BLOCK identifier RR
    ;

// {{/ block }}
endBlockInterpolation
    : LL SLASH BLOCK RR
    ;

// {{render "the-template" name="Dan" email=the.email.variable}}
renderStatement
locals [RenderStatement result]
    : LL RENDER attrValue attribute* RR
    ;

ifStatement
locals [IfStatement result]
    : ifInterpolation statement+ endIfInterpolation # IfOnlyStatement
    | ifInterpolation ifStatements+=statement+ elseInterpolation elseStatements+=statement+ endIfInterpolation # IfElseStatement
    ;

ifInterpolation
    : LL IF RR
    ;

elseInterpolation
    : LL ELSE RR
    ;

endIfInterpolation
    : LL SLASH IF RR
    ;

forStatement
locals [ForStatement result]
    : forInterpolation statement+ endForInterpolation
    ;

forInterpolation
    : LL FOR iter+=identifier IN coll+=compoundIdentifier RR
    ;

endForInterpolation
    : LL SLASH FOR RR
    ;

interpolation
locals [Interpolation result]
    : idInterpolation
    | attrInterpolation
    ;

// {{address.street.number}}
idInterpolation
locals [IdInterpolation result]
    : LL compoundIdentifier RR
    ;

// {{address street="Ferdinand" number="1" name=the.name}}
attrInterpolation
locals [AttrInterpolation result]
    : LL identifier attribute* RR
    ;

attribute
locals [Attribute result]
    : attributeWithValue
    | attributeWithIdentifier
    ;

// name="John"
attributeWithValue
locals [AttributeWithValue result]
    : identifier START_ATTR attrValue
    ;

// name = the.name.variable
attributeWithIdentifier
locals [AttributeWithIdentifier result]
    : identifier START_ATTR compoundIdentifier
    ;

attrValue
locals [String result]
    : START_ATTR_VALUE ATTR_TEXT END_ATTR_VALUE
    ;

compoundIdentifier
locals [CompoundIdentifier result]
    : IDENTIFIER (DOT IDENTIFIER)*
    ;

identifier
locals [Identifier result]
    : IDENTIFIER
    ;

text
locals [Text result]
    : TEXT
    ;