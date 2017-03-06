Document
  = WP_Block_List

WP_Block_List
  = WP_Block*

WP_Block
  = WP_Block_Balanced
  / WP_Block_Html

WP_Block_Balanced
  = s:WP_Block_Start ts:(!WP_Block_End c:Any { return c })+ e:WP_Block_End
  { return {
    blockType: s.blockType,
    attrs: s.attrs,
    rawContent: ts.join( '' ),
  } }

WP_Block_Html
  = ts:(!WP_Block_Balanced c:Any { return c })+
  {
    return {
      blockType: 'html',
      attrs: {},
      rawContent: ts.join('')
    }
  }

WP_Block_Start
  = "<!--" __ "wp:" blockType:WP_Block_Type attrs:WP_Block_Attribute_List _? "-->"
  { return {
    type: 'WP_Block_Start',
    blockType,
    attrs,
    text: text()
  } }

WP_Block_End
  = "<!--" __ "/wp" __ "-->"
  { return {
    type: 'WP_Block_End',
    text: text()
  } }

WP_Block_Type
  = head:ASCII_Letter tail:ASCII_AlphaNumeric*
  { return [ head ].concat( tail ).join('')  }

WP_Block_Attribute_List
  = as:(_+ attr:WP_Block_Attribute { return attr })*
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
  = head:ASCII_Letter tail:WP_Block_Attribute_Value_Char*
  { return [ head ].concat( tail ).join('') }

ASCII_AlphaNumeric
  = ASCII_Letter
  / ASCII_Digit
  / Special_Chars

WP_Block_Attribute_Value_Char
  = [^ \t\r\n]

ASCII_Letter
  = [a-zA-Z]

ASCII_Digit
  = [0-9]

Special_Chars
  = [\-\_]

Newline
  = [\r\n]

_
  = [ \t]

__
  = _+

Any
  = .
