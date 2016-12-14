Document
  = Token*

Token
  = s:WP_Block_Start ts:(!WP_Block_End t:Token { return t })+ e:WP_Block_End
  { return {
    type: 'WP_Block',
    attrs: s.attrs,
    startText: s.text,
    endText: e.text,
    children: ts
  } }
  / HTML_Comment
  / HTML_Tag_Open
  / HTML_Tag_Close
  / ts:HTML_Text+
  { return {
    type: 'Text',
    value: ts.join('')
  } }

HTML_Text
  = [a-zA-Z0-9,.:;'"`()\[\] \t\r\n/\\!]

WP_Block_Start
  = "<!--" __ "@block-start" attrs:WP_Block_Attribute_List? _? "-->"
  { return {
    type: 'WP_Block_Start',
    attrs,
    text: text()
  } }

WP_Block_End
  = "<!--" __ "@block-end" __ "-->"
  { return {
    type: 'WP_Block_End',
    text: text()
  } }

WP_Block_Attribute_List
  = as:(_+ attr:WP_Block_Attribute { return attr })+
  { return as.reduce( ( attrs, [ name, value ] ) => Object.assign(
    attrs,
    { [ name ]: value }
  ), {} ) }

WP_Block_Attribute
  = name:WP_Block_Attribute_Name ":" value:WP_Block_Attribute_Value
  { return [ name, value ] }

WP_Block_Attribute_Name
  = head:ASCII_Letter tail:ASCII_AlphaNumeric*
  { return [ head ].concat( tail ).join('')  }

WP_Block_Attribute_Value
  = head:ASCII_Letter tail:ASCII_AlphaNumeric*
  { return [ head ].concat( tail ).join('') }

HTML_Comment
  = "<!--" cs:(!"-->" c:. { return c })* "-->"
  { return {
    type: "HTML_Comment",
    innerText: cs.join(''),
    text: text()
  } }

HTML_Tag_Open
  = "<" name:HTML_Tag_Name attrs:HTML_Attribute_List? _* ">"
  { return {
    type: 'HTML_Tag_Open',
    name,
    attrs,
    text: text()
  } }

HTML_Tag_Close
  = "</" name: HTML_Tag_Name _* ">"
  { return {
    type: 'HTML_Tag_Close',
    name,
    text: text()
  } }

HTML_Tag_Name
  = cs:HTML_Tag_Name_Character+
  { return cs.join('') }

HTML_Tag_Name_Character
  = ASCII_Letter
  / ASCII_Digit

HTML_Attribute_List
  = as:(_+ a:HTML_Attribute_Item { return a })+
  { return as.reduce( ( attrs, [ name, value ] ) => Object.assign(
    attrs,
    { [ name ]: value }
  ), {} ) }

HTML_Attribute_Item
  = HTML_Attribute_Quoted
  / HTML_Attribute_Unquoted
  / HTML_Attribute_Empty

HTML_Attribute_Empty
  = name:HTML_Attribute_Name
  { return [ name, true ] }

HTML_Attribute_Unquoted
  = name:HTML_Attribute_Name _* "=" _* value:[a-zA-Z0-9]+
  { return [ name, value.join('') ] }

HTML_Attribute_Quoted
  = name:HTML_Attribute_Name _* "=" _* '"' value:(!'"' c:. { return c })+ '"'
  { return [ name, value.join('') ] }
  / name:HTML_Attribute_Name _* "=" _* "'" value:(!"'" c:. { return c })+ "'"
  { return [ name, value.join('') ] }

HTML_Attribute_Name
  = cs:[a-zA-Z0-9:.]+
  { return cs.join('') }

ASCII_AlphaNumeric
  = ASCII_Letter
  / ASCII_Digit

ASCII_Letter
  = [a-zA-Z]

ASCII_Digit
  = [0-9]

Newline
  = [\r\n]

_
  = [ \t]

__
  = _+
