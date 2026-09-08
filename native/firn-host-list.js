import * as ffi2e2f6669726e2d686f73742d6c6973742d6f732e6d6a73 from "./firn-host-list-os.mjs";
import * as ffi6e6f64653a6673 from "node:fs";
// Generated from checked Clause canonical executable IR.

function fail(code){throw new Error(code);}
function equal(a,b){
 if(a===b)return true;
 if(a===null||b===null||typeof a!=='object'||typeof b!=='object'||Array.isArray(a)!==Array.isArray(b))return false;
 if(Array.isArray(a))return a.length===b.length&&a.every((v,i)=>equal(v,b[i]));
 const keys=Object.keys(a);return keys.length===Object.keys(b).length&&keys.every(k=>Object.hasOwn(b,k)&&equal(a[k],b[k]));
}
function finite(value){if(typeof value!=='number'||!Number.isFinite(value))fail('NumericDomain');return value===0?0:value;}
function scalarText(value){
 if(typeof value!=='number')return String(value);
 const rendered=String(finite(value));
 if(!rendered.includes('e'))return rendered;
 const negative=rendered.startsWith('-');
 const [mantissa,exponent]=rendered.replace(/^-/, '').split('e');
 const digits=mantissa.replace('.', '');
 const point=(mantissa.includes('.')?mantissa.indexOf('.'):mantissa.length)+Number(exponent);
 const decimal=point<=0?'0.'+'0'.repeat(-point)+digits:point>=digits.length?digits+'0'.repeat(point-digits.length):digits.slice(0,point)+'.'+digits.slice(point);
 return (negative?'-':'')+decimal;
}
function text(value){if(typeof value!=='string'||!value.isWellFormed()||new TextEncoder().encode(value).length>16777216)fail('TextDomain');return value;}
function validate(value,kind){
 switch(kind[0]){
 case 'number':finite(value);break;
 case 'text':text(value);break;
 case 'boolean':if(typeof value!=='boolean')fail('TypeMismatch');break;
 case 'referent':if(value===null||typeof value!=='object'||value.domain!==kind[1]||!Number.isInteger(value.identity)||value.identity<=0||value.identity>4294967295)fail('TypeMismatch');break;
 case 'sequence':if(!Array.isArray(value))fail('TypeMismatch');for(let i=0;i<value.length;i++){if(!Object.hasOwn(value,i))fail('TypeMismatch');validate(value[i],kind[1]);}break;
 case 'record':if(value===null||typeof value!=='object'||Array.isArray(value)||Object.keys(value).length!==kind[1].length)fail('TypeMismatch');for(const [key,type] of kind[1]){if(!Object.hasOwn(value,key))fail('TypeMismatch');validate(value[key],type);}break;
 default:fail('TypeMismatch');
 }
}
function crossing(value,kind){
 validate(value,kind);
 if(kind[0]==='sequence')return Object.freeze(value.map(v=>crossing(v,kind[1])));
 if(kind[0]==='record')return Object.freeze(Object.fromEntries(kind[1].map(([key,type])=>[key,crossing(value[key],type)])));
 return value;
}
function drop(value,count){if(!Number.isFinite(count)||!Number.isInteger(count)||count<0)fail('NumericDomain');return Object.freeze(value.slice(count));}
function facet(value,domain,members){if(value===null||typeof value!=='object')return undefined;if(value.domain===domain)return value;if(members.includes(value.identity))return Object.freeze({domain,identity:value.identity});return undefined;}
function requireFacet(value,domain,members){const result=facet(value,domain,members);if(result===undefined)fail('TypeMismatch');return result;}
function concatenate(a,b){return text(text(a)+text(b));}
function add(a,b){return finite(finite(a)+finite(b));}
function subtract(a,b){return finite(finite(a)-finite(b));}
function multiply(a,b){return finite(finite(a)*finite(b));}
function divide(a,b){return finite(finite(a)/finite(b));}
function greater(a,b){return finite(a)>finite(b);}
function lessEqual(a,b){return finite(a)<=finite(b);}
function startsWith(a,b){return text(a).startsWith(text(b));}
function containsText(a,b){return text(a).includes(text(b));}
function row(table,subject){return table.rows.find(([key])=>equal(key,subject))?.[1];}
function present(table,subject){validate(subject,['referent',table.domain]);return row(table,subject)!==undefined;}
function readOne(table,subject){const values=row(table,subject);if(values?.length!==1)fail('MissingState');return values[0];}
function stage(pending,pre,slot,mode,subject,value){
 const table=pre[slot];validate(subject,['referent',table.domain]);validate(value,table.kind);
 if(table.cardinality==='many'){
  if(mode!==1&&mode!==2)fail('TypeMismatch');
 }else if(mode===1)fail('TypeMismatch');
 if(pending.some(effect=>effect.slot===slot&&equal(effect.subject,subject)&&(table.cardinality!=='many'||equal(effect.value,value))))fail('ConflictingStateEffects');
 pending.push({slot,mode,subject,value});
}
function commit(pre,pending){
 const next=pre.map(table=>({...table,rows:table.rows.map(([subject,values])=>[subject,[...values]])}));
 for(const {slot,mode,subject,value} of pending){
  const table=next[slot];let index=table.rows.findIndex(([key])=>equal(key,subject));
  if(mode===0){if(index<0)table.rows.push([subject,[value]]);else table.rows[index]=[subject,[value]];}
  else if(mode===1){if(index<0)table.rows.push([subject,[value]]);else if(!table.rows[index][1].some(prior=>equal(prior,value)))table.rows[index][1].push(value);}
  else{
   if(index<0)fail('MissingState');
   const values=table.rows[index][1];const at=values.findIndex(prior=>equal(prior,value));
   if(at<0)fail('MissingState');values.splice(at,1);if(values.length===0)table.rows.splice(index,1);
  }
 }
 validateContracts(next);return next;
}
function validateContracts(tables){
 const participants=[];
 for(const table of tables)for(const [subject,values] of table.rows){participants.push(subject);if(table.kind[0]==='referent')participants.push(...values);}
 for(const table of tables)if(table.total){if(table.cardinality!=='one')fail('TypeMismatch');for(const subject of participants)if(subject.domain===table.domain&&row(table,subject)?.length!==1)fail('MissingState');}
}

function callable0(...args){
if(args.length!==1)fail("ArgumentCount");
args[0]=crossing(args[0],["text"]);
const result=crossing((0,ffi2e2f6669726e2d686f73742d6c6973742d6f732e6d6a73["listDirectory"])(args[0]),["record",[["names",["sequence",["text"]]],["status",["number"]]]]);
validate(result,["record",[["names",["sequence",["text"]]],["status",["number"]]]]);
return result;
}
function callable1(...args){
if(args.length!==1)fail("ArgumentCount");
args[0]=crossing(args[0],["text"]);
const result=crossing((0,ffi2e2f6669726e2d686f73742d6c6973742d6f732e6d6a73["pathKind"])(args[0]),["record",[["kind",["number"]],["status",["number"]]]]);
validate(result,["record",[["kind",["number"]],["status",["number"]]]]);
return result;
}
function callable2(...args){
if(args.length!==2)fail("ArgumentCount");
args[0]=crossing(args[0],["number"]);
args[1]=crossing(args[1],["text"]);
const result=crossing((0,ffi6e6f64653a6673["writeSync"])(args[0],args[1]),["number"]);
validate(result,["number"]);
return result;
}
function callable3(...args){
if(args.length!==0)fail("ArgumentCount");
const result=Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([])]]));
validate(result,["record",[["error",["text"]],["names",["sequence",["text"]]]]]);
return result;
}
function callable4(...args){
if(args.length!==3)fail("ArgumentCount");
args[0]=crossing(args[0],["text"]);
args[1]=crossing(args[1],["text"]);
args[2]=crossing(args[2],["number"]);
const result=concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(args[0]))," '"),scalarText(args[1])),"': errno "),scalarText(args[2])),"\n");
validate(result,["text"]);
return result;
}
function callable5(...args){
if(args.length!==3)fail("ArgumentCount");
args[0]=crossing(args[0],["record",[["error",["text"]],["names",["sequence",["text"]]]]]);
args[1]=crossing(args[1],["text"]);
args[2]=crossing(args[2],["record",[["kind",["number"]],["status",["number"]]]]);
const result=(equal(args[2]["status"],0)?(equal(args[2]["kind"],2)?Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([...(args[0]["names"]),(args[1])])]])):args[0]):(equal(args[2]["status"],2)?args[0]:Object.freeze(Object.fromEntries([["error",((b0)=>(((b1)=>(((b2)=>(concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(b0))," '"),scalarText(b1)),"': errno "),scalarText(b2)),"\n")))(args[2]["status"])))(concatenate(concatenate("hosts/",scalarText(args[1])),""))))("cannot inspect")],["names",args[0]["names"]]]))));
validate(result,["record",[["error",["text"]],["names",["sequence",["text"]]]]]);
return result;
}
function callable6(...args){
if(args.length!==3)fail("ArgumentCount");
args[0]=crossing(args[0],["text"]);
args[1]=crossing(args[1],["record",[["error",["text"]],["names",["sequence",["text"]]]]]);
args[2]=crossing(args[2],["text"]);
const result=(equal(args[1]["error"],"")?((b4)=>(((b5)=>(((b6)=>((equal(b6["status"],0)?(equal(b6["kind"],2)?Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([...(b4["names"]),(b5)])]])):b4):(equal(b6["status"],2)?b4:Object.freeze(Object.fromEntries([["error",((b7)=>(((b8)=>(((b9)=>(concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(b7))," '"),scalarText(b8)),"': errno "),scalarText(b9)),"\n")))(b6["status"])))(concatenate(concatenate("hosts/",scalarText(b5)),""))))("cannot inspect")],["names",b4["names"]]]))))))(((b3)=>(crossing((0,ffi2e2f6669726e2d686f73742d6c6973742d6f732e6d6a73["pathKind"])(b3),["record",[["kind",["number"]],["status",["number"]]]])))(concatenate(concatenate(concatenate(concatenate("",scalarText(args[0])),"/hosts/"),scalarText(args[2])),"")))))(args[2])))(args[1]):args[1]);
validate(result,["record",[["error",["text"]],["names",["sequence",["text"]]]]]);
return result;
}
function callable7(...args){
if(args.length!==2)fail("ArgumentCount");
args[0]=crossing(args[0],["text"]);
args[1]=crossing(args[1],["sequence",["text"]]);
const result=((xs,initial)=>{let b10=initial;for(const b11 of xs){b10=(((b12)=>(((b13)=>(((b14)=>((equal(b13["error"],"")?((b15)=>(((b16)=>(((b18)=>((equal(b18["status"],0)?(equal(b18["kind"],2)?Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([...(b15["names"]),(b16)])]])):b15):(equal(b18["status"],2)?b15:Object.freeze(Object.fromEntries([["error",((b19)=>(((b20)=>(((b21)=>(concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(b19))," '"),scalarText(b20)),"': errno "),scalarText(b21)),"\n")))(b18["status"])))(concatenate(concatenate("hosts/",scalarText(b16)),""))))("cannot inspect")],["names",b15["names"]]]))))))(((b17)=>(crossing((0,ffi2e2f6669726e2d686f73742d6c6973742d6f732e6d6a73["pathKind"])(b17),["record",[["kind",["number"]],["status",["number"]]]])))(concatenate(concatenate(concatenate(concatenate("",scalarText(b12)),"/hosts/"),scalarText(b14)),"")))))(b14)))(b13):b13)))(b11)))(b10)))(args[0]));}return b10;})((args[1]),(Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([])]]))));
validate(result,["record",[["error",["text"]],["names",["sequence",["text"]]]]]);
return result;
}
function callable8(...args){
if(args.length!==2)fail("ArgumentCount");
args[0]=crossing(args[0],["text"]);
args[1]=crossing(args[1],["record",[["names",["sequence",["text"]]],["status",["number"]]]]);
const result=(equal(args[1]["status"],0)?(greater((args[1]["names"]).length,16384)?Object.freeze(Object.fromEntries([["error",((b22)=>(((b23)=>(((b24)=>(concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(b22))," '"),scalarText(b23)),"': errno "),scalarText(b24)),"\n")))(27)))("hosts")))("cannot list")],["names",Object.freeze([])]])):((b25)=>(((b26)=>(((xs,initial)=>{let b27=initial;for(const b28 of xs){b27=(((b29)=>(((b30)=>(((b31)=>((equal(b30["error"],"")?((b32)=>(((b33)=>(((b35)=>((equal(b35["status"],0)?(equal(b35["kind"],2)?Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([...(b32["names"]),(b33)])]])):b32):(equal(b35["status"],2)?b32:Object.freeze(Object.fromEntries([["error",((b36)=>(((b37)=>(((b38)=>(concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(b36))," '"),scalarText(b37)),"': errno "),scalarText(b38)),"\n")))(b35["status"])))(concatenate(concatenate("hosts/",scalarText(b33)),""))))("cannot inspect")],["names",b32["names"]]]))))))(((b34)=>(crossing((0,ffi2e2f6669726e2d686f73742d6c6973742d6f732e6d6a73["pathKind"])(b34),["record",[["kind",["number"]],["status",["number"]]]])))(concatenate(concatenate(concatenate(concatenate("",scalarText(b29)),"/hosts/"),scalarText(b31)),"")))))(b31)))(b30):b30)))(b28)))(b27)))(b25));}return b27;})((b26),(Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([])]]))))))(args[1]["names"])))(args[0])):(equal(args[1]["status"],2)?Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([])]])):Object.freeze(Object.fromEntries([["error",((b39)=>(((b40)=>(((b41)=>(concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(b39))," '"),scalarText(b40)),"': errno "),scalarText(b41)),"\n")))(args[1]["status"])))("hosts")))("cannot list")],["names",Object.freeze([])]]))));
validate(result,["record",[["error",["text"]],["names",["sequence",["text"]]]]]);
return result;
}
function callable9(...args){
if(args.length!==1)fail("ArgumentCount");
args[0]=crossing(args[0],["sequence",["text"]]);
const result=concatenate(concatenate(concatenate(concatenate("Hosts (",scalarText((args[0]).length)),"):\n"),scalarText(text((Object.freeze((args[0]).map((b42)=>(concatenate(concatenate("  ",scalarText(b42)),"\n"))))).join("")))),"");
validate(result,["text"]);
return result;
}
function callable10(...args){
if(args.length!==1)fail("ArgumentCount");
args[0]=crossing(args[0],["record",[["error",["text"]],["names",["sequence",["text"]]]]]);
const result=(equal(args[0]["error"],"")?Object.freeze(Object.fromEntries([["error",""],["output",((b43)=>(concatenate(concatenate(concatenate(concatenate("Hosts (",scalarText((b43).length)),"):\n"),scalarText(text((Object.freeze((b43).map((b44)=>(concatenate(concatenate("  ",scalarText(b44)),"\n"))))).join("")))),"")))(Object.freeze([...(args[0]["names"])].sort()))],["status",0]])):Object.freeze(Object.fromEntries([["error",args[0]["error"]],["output",""],["status",1]])));
validate(result,["record",[["error",["text"]],["output",["text"]],["status",["number"]]]]);
return result;
}
function callable11(...args){
if(args.length!==1)fail("ArgumentCount");
args[0]=crossing(args[0],["text"]);
const result=((b68)=>((equal(b68["error"],"")?Object.freeze(Object.fromEntries([["error",""],["output",((b69)=>(concatenate(concatenate(concatenate(concatenate("Hosts (",scalarText((b69).length)),"):\n"),scalarText(text((Object.freeze((b69).map((b70)=>(concatenate(concatenate("  ",scalarText(b70)),"\n"))))).join("")))),"")))(Object.freeze([...(b68["names"])].sort()))],["status",0]])):Object.freeze(Object.fromEntries([["error",b68["error"]],["output",""],["status",1]])))))(((b46)=>(((b47)=>((equal(b47["status"],0)?(greater((b47["names"]).length,16384)?Object.freeze(Object.fromEntries([["error",((b48)=>(((b49)=>(((b50)=>(concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(b48))," '"),scalarText(b49)),"': errno "),scalarText(b50)),"\n")))(27)))("hosts")))("cannot list")],["names",Object.freeze([])]])):((b51)=>(((b52)=>(((xs,initial)=>{let b53=initial;for(const b54 of xs){b53=(((b55)=>(((b56)=>(((b57)=>((equal(b56["error"],"")?((b58)=>(((b59)=>(((b61)=>((equal(b61["status"],0)?(equal(b61["kind"],2)?Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([...(b58["names"]),(b59)])]])):b58):(equal(b61["status"],2)?b58:Object.freeze(Object.fromEntries([["error",((b62)=>(((b63)=>(((b64)=>(concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(b62))," '"),scalarText(b63)),"': errno "),scalarText(b64)),"\n")))(b61["status"])))(concatenate(concatenate("hosts/",scalarText(b59)),""))))("cannot inspect")],["names",b58["names"]]]))))))(((b60)=>(crossing((0,ffi2e2f6669726e2d686f73742d6c6973742d6f732e6d6a73["pathKind"])(b60),["record",[["kind",["number"]],["status",["number"]]]])))(concatenate(concatenate(concatenate(concatenate("",scalarText(b55)),"/hosts/"),scalarText(b57)),"")))))(b57)))(b56):b56)))(b54)))(b53)))(b51));}return b53;})((b52),(Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([])]]))))))(b47["names"])))(b46)):(equal(b47["status"],2)?Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([])]])):Object.freeze(Object.fromEntries([["error",((b65)=>(((b66)=>(((b67)=>(concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(b65))," '"),scalarText(b66)),"': errno "),scalarText(b67)),"\n")))(b47["status"])))("hosts")))("cannot list")],["names",Object.freeze([])]]))))))(((b45)=>(crossing((0,ffi2e2f6669726e2d686f73742d6c6973742d6f732e6d6a73["listDirectory"])(b45),["record",[["names",["sequence",["text"]]],["status",["number"]]]])))(concatenate(concatenate("",scalarText(args[0])),"/hosts")))))(args[0]));
validate(result,["record",[["error",["text"]],["output",["text"]],["status",["number"]]]]);
return result;
}
export { callable11 as "host-list" };
function callable12(...args){
if(args.length!==1)fail("ArgumentCount");
args[0]=crossing(args[0],["record",[["error",["text"]],["output",["text"]],["status",["number"]]]]);
const result=((b76)=>(((b75)=>(args[0]["status"]))(((b73)=>(((b74)=>(crossing((0,ffi6e6f64653a6673["writeSync"])(b73,b74),["number"])))(args[0]["error"])))(2))))(((b71)=>(((b72)=>(crossing((0,ffi6e6f64653a6673["writeSync"])(b71,b72),["number"])))(args[0]["output"])))(1));
validate(result,["number"]);
return result;
}
function callable13(...args){
if(args.length!==1)fail("ArgumentCount");
args[0]=crossing(args[0],["sequence",["text"]]);
const result=(equal(args[0],Object.freeze(["host","list"]))?true:equal(args[0],Object.freeze(["host","list","all"])));
validate(result,["boolean"]);
return result;
}
export { callable13 as "handles" };
function callable14(...args){
if(args.length!==2)fail("ArgumentCount");
args[0]=crossing(args[0],["text"]);
args[1]=crossing(args[1],["sequence",["text"]]);
const result=((b105)=>(((b108)=>(((b111)=>(b105["status"]))(((b109)=>(((b110)=>(crossing((0,ffi6e6f64653a6673["writeSync"])(b109,b110),["number"])))(b105["error"])))(2))))(((b106)=>(((b107)=>(crossing((0,ffi6e6f64653a6673["writeSync"])(b106,b107),["number"])))(b105["output"])))(1))))((((b77)=>((equal(b77,Object.freeze(["host","list"]))?true:equal(b77,Object.freeze(["host","list","all"])))))(args[1])?((b78)=>(((b102)=>((equal(b102["error"],"")?Object.freeze(Object.fromEntries([["error",""],["output",((b103)=>(concatenate(concatenate(concatenate(concatenate("Hosts (",scalarText((b103).length)),"):\n"),scalarText(text((Object.freeze((b103).map((b104)=>(concatenate(concatenate("  ",scalarText(b104)),"\n"))))).join("")))),"")))(Object.freeze([...(b102["names"])].sort()))],["status",0]])):Object.freeze(Object.fromEntries([["error",b102["error"]],["output",""],["status",1]])))))(((b79)=>(((b81)=>((equal(b81["status"],0)?(greater((b81["names"]).length,16384)?Object.freeze(Object.fromEntries([["error",((b82)=>(((b83)=>(((b84)=>(concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(b82))," '"),scalarText(b83)),"': errno "),scalarText(b84)),"\n")))(27)))("hosts")))("cannot list")],["names",Object.freeze([])]])):((b85)=>(((b86)=>(((xs,initial)=>{let b87=initial;for(const b88 of xs){b87=(((b89)=>(((b90)=>(((b91)=>((equal(b90["error"],"")?((b92)=>(((b93)=>(((b95)=>((equal(b95["status"],0)?(equal(b95["kind"],2)?Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([...(b92["names"]),(b93)])]])):b92):(equal(b95["status"],2)?b92:Object.freeze(Object.fromEntries([["error",((b96)=>(((b97)=>(((b98)=>(concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(b96))," '"),scalarText(b97)),"': errno "),scalarText(b98)),"\n")))(b95["status"])))(concatenate(concatenate("hosts/",scalarText(b93)),""))))("cannot inspect")],["names",b92["names"]]]))))))(((b94)=>(crossing((0,ffi2e2f6669726e2d686f73742d6c6973742d6f732e6d6a73["pathKind"])(b94),["record",[["kind",["number"]],["status",["number"]]]])))(concatenate(concatenate(concatenate(concatenate("",scalarText(b89)),"/hosts/"),scalarText(b91)),"")))))(b91)))(b90):b90)))(b88)))(b87)))(b85));}return b87;})((b86),(Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([])]]))))))(b81["names"])))(b79)):(equal(b81["status"],2)?Object.freeze(Object.fromEntries([["error",""],["names",Object.freeze([])]])):Object.freeze(Object.fromEntries([["error",((b99)=>(((b100)=>(((b101)=>(concatenate(concatenate(concatenate(concatenate(concatenate(concatenate("firn tag resolve: ",scalarText(b99))," '"),scalarText(b100)),"': errno "),scalarText(b101)),"\n")))(b81["status"])))("hosts")))("cannot list")],["names",Object.freeze([])]]))))))(((b80)=>(crossing((0,ffi2e2f6669726e2d686f73742d6c6973742d6f732e6d6a73["listDirectory"])(b80),["record",[["names",["sequence",["text"]]],["status",["number"]]]])))(concatenate(concatenate("",scalarText(b78)),"/hosts")))))(b78))))(args[0]):Object.freeze(Object.fromEntries([["error","Usage: firn host list [all]\n"],["output",""],["status",64]]))));
validate(result,["number"]);
return result;
}
export { callable14 as "run" };
