/*
  * utah language definition
  * copyright by Nobuaki Tanaka 2014
  * All rights reserved
  */

grammar utah01;

ID : [a-zA-Z][a-zA-Z0-9]* ;
WS : [ \r\t\n]+ -> skip ;

start : elements ;

elements : 
    activeElement 
    | activeElement elements 
;

activeElement returns [String val] : 
    'activeElement' activeElementBody ID ';' 
; 

activeElementBody returns [String val] : 
    '{' portPart statePart transitionPart '}' 
        { $val = $portPart.val + ", \n\n" + $statePart.val + ", \n\n" +  $transitionPart.val; }    
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
        {$val = "\"" + $ID.text + "\"" ;} 
    | ID '{' stateDefinitions '}'   
        {$val = "\"" + $ID.text + "\"" + " {" + $stateDefinitions.val + "}"  ;} 
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
        { $val = "{ \"from\" : \"" + $from.text + "\" ," +  "\"to\" : \"" + $to.text + "\" ,\n\t" + $messageReception.val  + " , \n\t" + $guard.val +  " , " + $messageProcessing.val
            + " \n } "; }
;

transitionsD returns [String val] : // Capital D for dummy. 
    transitions {$val = $transitions.val;} 
;

from : ID ;
to : ID ;

messageReception returns [String val] :
    messageName 
        { $val = "\"message\" : {\"name\" : \""  + $messageName.text +   "\" ,\"type\" : NULL }" ;}
    | messageName '(' typeOfArgument ')'
        { $val = "\"message\" : {\"name\" : \"" + $messageName.text + "\" ," + $typeOfArgument.val  +  "}" ;}
;

typeOfArgument returns [String val]:
        {$val = "\"type\" : NULL " ; }
    | 'type' argType 
        {$val = "\"type\" : \"" + $argType.text + "\""; }
;

argType : ID ;

guard returns [String val]:
		// empty
       {$val = "\"guard\" : NULL" ;}
    | '[' guardName ']'
       {$val = "\"guard\" : {\"name\" : \"" + $guardName.text + "\", \"arg\" : NULL }" ;}
    | '[' guardName '(' ')' ']'
       {$val = "\"guard\" : {\"name\" : \"" + $guardName.text + "\", \"arg\" : NULL }" ;}
    | '[' guardName '(' givenArgument ')' ']'
       {$val = "\"guard\" : {\"name\" : \"" + $guardName.text + "\", \"arg\" : \"" + $givenArgument.text  +  "\" }" ;}
;

guardName : ID ;
givenArgument : stringLiteral ;

messageProcessing returns [String val]:
        //{$val = "NULL"; }
        {$val = "\n\t\"methodInvocation\" : NULL, \"resultHandling\" : NULL"; }
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
    port '->' messageName messageEmissionParams
        { $val = "\"messageEmission\" : \n\t\t\t{\"port\" : \"" + $port.text + "\" ," + 
        "\"messageName\" : \"" + $messageName.text +  "\" ," +
        $messageEmissionParams.val + "}" ;}
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
    'port' '{' listOfPort '}'
    { $val = "\"port\" : \n [" + $listOfPort.val + "] ";}
;

listOfPort returns [String val]:
    port listOfPortD
    { $val = "\"" + $port.text + "\"" + $listOfPortD.val;}
;

listOfPortD returns [String val]:
    { $val =""; }
    | ',' listOfPort
    { $val = " , " + $listOfPort.val ; }
;

port : ID ;
messageName : ID ;

stringLiteral : STRING+ ;
STRING : '"' ( '\\"' | . )*? '"' ; // match "foo", "\"", "x\"\"y", ...
