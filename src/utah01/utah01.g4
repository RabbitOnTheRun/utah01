/*
  * utah language definition
  * copyright by Nobuaki Tanaka 2014
  * All rights reserved
  */

grammar utah01;

ID : [a-zA-Z_][a-zA-Z0-9_]* ;
WS : [ \r\t\n]+ -> skip ;

start : elements ;

elements : 
    activeElement 
    | activeElement elements 
;

activeElement returns [String val] : 
    'activeElement' activeElementBody ID ';' 
    {
        SymbolTable.state.clear();
        SymbolTable.outPort.clear();
        SymbolTable.acceptableMessage.clear();
        SymbolTable.emitMessage.clear();
    }
; 

activeElementBody returns [String val] : 
    '{' portPart statePart transitionPart '}' 
        { $val = $portPart.val + ", \n\n" + $statePart.val + ", \n\n" 
            +  $transitionPart.val + ", \n\n" + SymbolTable.makeAcceptableMessageList()
            + SymbolTable.makeEmitMessageList(); 
            SymbolTable.count++; }    
;

statePart returns [String val] : 
    'state' '{' stateDefinitions '}'
        {$val = "\"state\" : \n [" + $stateDefinitions.val + "] ";}
;

stateDefinitions returns [String val] : 
    stateDefinition ',' stateDefinitionsD 
        {$val = $stateDefinition.val + " , " + $stateDefinitionsD.val;}
    | stateDefinition
        {$val = $stateDefinition.val;}
;

stateDefinition returns [String val]: 
    ID 
        {$val = "[ \"" + $ID.text + "\" , [] ]" ;
        SymbolTable.state.add($ID.text); } 
    | ID '{' stateDefinitions '}'   
        {$val = "[ \"" + $ID.text + "\"" + ", [" + $stateDefinitions.val + "] ]"  ;
        SymbolTable.state.add($ID.text); } 
;

stateDefinitionsD returns [String val]: 
    stateDefinitions {$val = $stateDefinitions.val; }
;

transitionPart returns [String val] : 
    'transition' '{' transitions '}' 
        {$val = "\"transition\" : [ \n" + $transitions.val + "\n] ";}
;

transitions returns [String val] : 
    transition transitionsD {$val = $transition.val + ", \n\n" + $transitionsD.val;}
    | transition {$val = $transition.val;}
;

transition returns [String val]:
    from '->' to ':' messageReception guard messageProcessing ';'
        { $val = "{ \"from\" : \"" + $from.val + "\" ," +  "\"to\" : \"" + $to.text 
            + "\" ,\n\t" + $messageReception.val  + " , \n\t" + $guard.val +  " , "
            + $messageProcessing.val + " \n } "; 
        }
;

transitionsD returns [String val] : // Capital D for dummy. 
    transitions {$val = $transitions.val;} 
;

from returns [String val] : 
    ID 
        {   if (false == SymbolTable.state.contains($ID.text)) {
                System.out.println("State definition from not found : " + $ID.text);
                System.out.println("LINE : " + _localctx.start.getLine());
            }
            $val = $ID.text;
        }
;
to returns [String val] : 
    ID 
        {   if (false == SymbolTable.state.contains($ID.text)) {
                System.out.println("State definition to not found : " + $ID.text);
            }
            $val = $ID.text;
        }
;

messageReception returns [String val] :
    messageNameR 
        { $val = "\"message\" : {\"name\" : \""  + $messageNameR.val +   "\" ,\"type\" : \"NULL\" }" ;}
    | messageNameR '(' typeOfArgument ')'
        { $val = "\"message\" : {\"name\" : \"" + $messageNameR.val + "\" ," + $typeOfArgument.val  +  "}" ;}
;

typeOfArgument returns [String val]:
        {$val = "\"type\" : \"NULL\" " ; }
    | 'type' argType 
        {$val = "\"type\" : \"" + $argType.text + "\""; }
;

argType : ID ;

guard returns [String val]:
		// empty
       //{$val = "\"guard\" : \"NULL\"" ;}
       {$val = "\"guard\" : {\"name\" : \"NULL\", \"arg\" : \"NULL\" }" ;}
    | '[' guardName ']'
       {$val = "\"guard\" : {\"name\" : \"" + $guardName.text + "\", \"arg\" : \"NULL\" }" ;}
    | '[' guardName '(' ')' ']'
       {$val = "\"guard\" : {\"name\" : \"" + $guardName.text + "\", \"arg\" : \"NULL\" }" ;}
    | '[' guardName '(' givenArgument ')' ']'
       {$val = "\"guard\" : {\"name\" : \"" + $guardName.text + "\", \"arg\" : \"" + $givenArgument.text  +  "\" }" ;}
;

guardName : ID ;
givenArgument : stringLiteral ;

messageProcessing returns [String val]:
        //{$val = "NULL"; }
        {$val = "\n\t\"methodInvocation\" : {\"methodName\" : \"NULL\" , \"methodArgument\" : \"NULL\" }, \n\t\"resultHandling\" : []"; }
    | '/' resultHandling
        {$val = "\n\t\"methodInvocation\" : {\"methodName\" : \"NULL\" , \"methodArgument\" : \"NULL\" }, \n\t" + $resultHandling.val; }
    | '/' methodInvocation resultHandling
        {$val = "\n\t" + $methodInvocation.val + " ,\n\t" + $resultHandling.val; }
;

methodInvocation returns [String val]:  
    methodName methodArgument
    { $val = "\"methodInvocation\" : {" +
    "\"methodName\" : \"" + $methodName.text + "\" , " +
    "\"methodArgument\" : "+ $methodArgument.val + " }";}
;

methodName : ID ;

methodArgument returns [String val]:
    '('  ')'
    {$val = "\"NULL\""; }
    | '(' givenArgument ')' 
    {$val = $givenArgument.text; }
;                  

resultHandling returns [String val]:
    { $val = "\"resultHandling\" : []"; }
    | 'emits' '{' listOfExternalEffect '}'
    { $val = "\"resultHandling\" : [ \n" + $listOfExternalEffect.val + "\n\t ]"; }
;    

listOfExternalEffect returns [String val]:
    externalEffect listOfExternalEffectD
    { $val = $externalEffect.val + $listOfExternalEffectD.val;}
;

listOfExternalEffectD returns [String val]:
    { $val =""; }
    | listOfExternalEffect
    { $val = " ,\n" + $listOfExternalEffect.val ; }
;

externalEffect returns [String val]:
    resultCode ':' messageEmission  ';' 
        { $val = "\t\t{\"resultCode\" : \"" + $resultCode.text + "\", " + $messageEmission.val + "\n\t\t}";}
    | messageEmission  ';' 
        { $val = "\t\t{\"resultCode\" : \"NULL\", " + $messageEmission.val + "\n\t\t}" ;}
;

resultCode : ID ;

messageEmission returns [String val]:
    portOut '->' messageName messageEmissionParams
        { $val = "\"messageEmission\" : \n\t\t\t{\"port\" : \"" + $portOut.val + "\" ," + 
        "\"messageName\" : \"" + $messageName.text +  "\" ," +
        $messageEmissionParams.val + "}" ;
        if (false == SymbolTable.outPort.contains($portOut.val)) {
            System.out.println("port not defined : " +  $portOut.val );
        }
        SymbolTable.emitMessage.add( new EmitMessage($portOut.val, $messageName.text) );
        }
;

messageEmissionParams returns [String val]:
    '(' ')'
        { $val = "\"argType\" : \"NULL\" ,\"givenArgument\" : \"NULL\" "; } 
    | '(' 'param' givenArgument ')'
        { $val = "\"argType\" : \"NULL\" ,\"givenArgument\" : \"" + $givenArgument.text + "\" "; } 
    | '(' 'type' argType ')'
        { $val = "\"argType\" : \"" + $argType.text +  "\" ,\"givenArgument\" : \"NULL\" "; } 
    | '(' 'type' argType ',' 'param' givenArgument ')'
        { $val = "\"argType\" : \"" + $argType.text +  "\" ,\"givenArgument\" : \"" + $givenArgument.text + "\" "; } 
;                          

portPart returns [String val]:
    'inPort' '{' listOfPortIn '}' 'outPort' '{' listOfPortOut '}'
    { $val = "\"inPort\" : \n [" + $listOfPortIn.val + "] , \n" + "\"outPort\" : \n [" + $listOfPortOut.val + "] " ;}
;

listOfPortIn returns [String val]:
    listOfPort  { $val = $listOfPort.val; }
;

listOfPortOut returns [String val]:
    listOfPort  { $val = $listOfPort.val; }
;

listOfPort returns [String val]:
    port listOfPortD
    { $val = "\"" + $port.val + "\"" + $listOfPortD.val;}
;

listOfPortD returns [String val]:
    { $val =""; }
    | ',' listOfPort
    { $val = " , " + $listOfPort.val ; }
;

port returns [String val]:
    ID { SymbolTable.outPort.add($ID.text); $val = $ID.text;}  
// include inPort bug
;
portOut returns [String val]:
    ID { $val = $ID.text; }  
;

messageName : ID ;

messageNameR returns [String val]:
    ID { SymbolTable.acceptableMessage.add($ID.text); 
        $val = $ID.text; }
;

stringLiteral : STRING+ ;
STRING : '"' ( '\\"' | . )*? '"' ; // match "foo", "\"", "x\"\"y", ...
