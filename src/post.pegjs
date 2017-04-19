{
  function orJSON( text ) {
    try {
      return JSON.parse( text );
    } catch (e) {
      return text;
    }
  }

  function orAsJSON( source ) {
    return Object.keys( source ).reduce( function( o, key ) {
      return Object.assign( o, { [ key ]: orJSON( source[ key ] ) } );
    }, {} );
  }

  function convert( token ) {
    if ( ! token || ! token.type ) {
      return token;
    }

    var children = token.children
      ? token.children.map( convert )
      : [];

    switch ( token.type ) {
      case 'HTML_Tag': return [ [ 'Tag', token.name ], token.attrs, children ];
      case 'HTML_Tag_Close': return [ [ '-Tag', token.name ] ];
      case 'HTML_Tag_Open': return [ [ '+Tag', token.name ], token.attrs ];
      case 'HTML_Void_Tag': return [ [ 'Tag', token.name ], token.attrs ];
      case 'Text': return token.value;
      case 'WP_Block': return [ [ 'Block', token.blockType ], token.attrs, children ];
      case 'WP_Block_Start': return [ [ '+Block', token.blockType ], token.attrs ];
      case 'WP_Block_End': return [ [ '-Block' ] ];
      case 'WP_Block__Image': return [ [ 'Block', 'core/image' ], { src: token.src }, convert( token.caption )  || [] ];
      case 'WP_Block__Quote': return [ [ 'Block', 'core/quote' ], { source: convert( token.source ) }, convert( token.quote ) ];
      default: return token;
    }
  }
}

Document
  = ts:Token*
  { return ts.map( convert ).filter( a => ! /^\s+$/.test( a ) ) }
  
Token
  = WP_Block__Image
  / WP_Block__Quote
  / WP_Block_Balanced
  / WP_Block_Start
  / WP_Block_End
  / HTML_Comment
  / HTML_Tag_Void
  / HTML_Tag_Balanced
  / HTML_Tag_Open
  / HTML_Tag_Close
  / ts:$(HTML_Text+)
  { return {
    type: 'Text',
    value: ts
  } }
  
HTML_Text
  = [^<]

WP_Block__Image
  = b:WP_Block_Balanced
  & { return (
      b.blockType === 'image' &&
      b.children.length <=2 &&
      b.children[ 0 ].type === 'HTML_Void_Tag' &&
      b.children[ 0 ].name === 'img'
    ) }
  { return {
    type: 'WP_Block__Image',
    src: b.children[ 0 ].attrs.src,
    caption: b.children[ 1 ]
  } }

WP_Block__Quote
  = b:WP_Block_Balanced
  & { return (
      b.blockType === 'quote' &&
      b.children.length === 2 &&
      b.children[ 1 ].type === 'HTML_Tag' &&
      b.children[ 1 ].name.toLowerCase() === 'cite'
    ) }
  { return {
    type: 'WP_Block__Quote',
    quote: b.children[ 0 ],
    source: b.children[ 1 ].children[ 0 ]
  } }

WP_Block_Balanced
  = s:WP_Block_Start children:(!WP_Block_End t:Token { return t })+ e:WP_Block_End
  { return {
    type: 'WP_Block',
    blockType: s.blockType,
    attrs: orAsJSON( s.attrs ),
    children
  } }
  
WP_Block_Start
  = "<!--" __ "wp:" blockType:WP_Block_Type attrs:HTML_Attribute_List _? "-->"
  { return {
    type: 'WP_Block_Start',
    blockType,
    attrs
  } }
  
WP_Block_End
  = "<!--" __ "/wp" __ "-->"
  { return {
    type: 'WP_Block_End'
  } }

WP_Block_Type
  = $(ASCII_Letter (ASCII_AlphaNumeric / "/" ASCII_AlphaNumeric)*)
 
HTML_Comment
  = "<!--" cs:(!"-->" c:. { return c })* "-->"
  { return {
    type: "HTML_Comment",
    innerText: cs.join('')
  } }

HTML_Tag_Void
  = t:HTML_Tag_Open
  & { return undefined !== {
      'br': true,
      'col': true,
      'embed': true,
      'hr': true,
      'img': true,
      'input': true
    }[ t.name.toLowerCase() ] }
  { return {
    type: 'HTML_Void_Tag',
    name: t.name,
    attrs: t.attrs
  } }
  
HTML_Tag_Balanced
  = s:HTML_Tag_Open
    children:(
      HTML_Tag_Balanced
    / (!(ct:HTML_Tag_Close & { return s.name === ct.name } ) t:Token { return t }))*
    e:HTML_Tag_Close
  & { return s.name === e.name }
  { return {
    type: 'HTML_Tag',
    name: s.name,
    attrs: s.attrs,
    children
  } }
  
HTML_Tag_Open
  = "<" name:HTML_Tag_Name attrs:HTML_Attribute_List _* ">"
  { return {
    type: 'HTML_Tag_Open',
    name,
    attrs
  } }

HTML_Tag_Close
  = "</" name:HTML_Tag_Name _* ">"
  { return {
    type: 'HTML_Tag_Close',
    name
  } }
  
HTML_Tag_Name
  = $(ASCII_Letter ASCII_AlphaNumeric*)
  
HTML_Attribute_List
  = as:(_+ a:HTML_Attribute_Item { return a })*
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
  = name:HTML_Attribute_Name _* "=" _* value:$([a-zA-Z0-9]+)
  { return [ name, value ] }
  
HTML_Attribute_Quoted
  = name:HTML_Attribute_Name _* "=" _* '"' value:$((!'"' .)*) '"'
  { return [ name, value ] }
  / name:HTML_Attribute_Name _* "=" _* "'" value:$((!"'" .)*) "'"
  { return [ name, value ] }
  
HTML_Attribute_Name
  = $([a-zA-Z0-9:.]+)

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
