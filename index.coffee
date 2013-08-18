root = exports ? this

#tokenize = (text, lang) ->
#  return text.match(/\b\w+\b/g)

tokenize = (text, lang) ->
  output = []
  currentToken = []
  for c in text
    if c in ' ,.!:-++|=()?'
      if currentToken.length > 0
        output.push currentToken.join('')
      output.push c
      currentToken = []
    else
      currentToken.push c
  if currentToken.length > 0
    output.push currentToken.join('')
    currentToken = []
  return output

getIPA = root.getIPA = (word, lang, callback) ->
  $.get('/getIPA?' + $.param({'lang': lang, 'word': word}), (ipa_pronunc) ->
    console.log ipa_pronunc
    callback(ipa_pronunc)
  )

getIPAOverlayId = (spanHovered) ->
  return spanHovered.attr('id') + '_ipaoverlay'

showIPA = (spanHovered) ->
  overlayId = getIPAOverlayId(spanHovered)
  overlaySpan = $('#' + overlayId)
  if overlaySpan? and overlaySpan.length? and overlaySpan.length > 0
    spanHovered.css('opacity', '0')
    overlaySpan.css('opacity', spanHovered.attr('origOpacity'))
  else
    getIPA(spanHovered.attr('tokenText'), 'en', (ipa) ->
      if ipa? and ipa != ''
        spanHovered.attr('ipa', ipa)
        #spanHovered.text('')
        #origColor = spanHovered.css('color')
        #if not origColor?
        origOpacity = '100'
        spanHovered.attr('origOpacity', origOpacity)
        spanHovered.css('opacity', 0)
        #$(document.documentElement).append("<span id='#{overlayId}'>")
        $(document.documentElement).append(spanHovered.clone(false).attr('id', overlayId))
        overlaySpan = $('#' + overlayId)
        overlaySpan.css(spanHovered.getStyleObject())
        overlaySpan.css('position', 'absolute')
        overlaySpan.text(ipa)
        overlaySpan.css('opacity', origOpacity)
        overlaySpan.css('pointer-events', 'none')
        overlaySpan.css('user-select', 'none')
        overlaySpan.css('moz-user-select', 'none')
        overlaySpan.css('khtml-user-select', 'none')
        overlaySpan.attr('unselectable', 'on')
        overlaySpan.offset(spanHovered.offset())
        overlaySpan.scaleToMatchTextWidth(spanHovered)
        #spanHovered.text(spanHovered.attr('tokenText'))
    )

hideIPA = (spanHovered) ->
  spanHovered.css('opacity', spanHovered.attr('origOpacity'))
  overlayId = getIPAOverlayId(spanHovered)
  overlaySpan = $('#' + overlayId)
  overlaySpan.css('opacity', 0)

#cloneParentFormatting = (parentNode, tokens) ->
#

xpos = (textNode) ->
  range = document.createRange()
  range.selectNodeContents(textNode)
  rects = range.getClientRects()
  if rects[0]?
    return rects[0].left
  #else
  #  return $(textNode).offset().left

ypos = (textNode) ->
  range = document.createRange()
  range.selectNodeContents(textNode)
  rects = range.getClientRects()
  if rects[0]?
    return rects[0].top
  #else
  #  return $(textNode).offset().top

moveToMatchRange = (textContainer, xp, yp) ->
  textContainer.offset({'left': xp, 'top': yp})

  #currentOffset = textContainer.offset()
  #currentXPos = xpos(textContainer[0])
  #currentYPos = ypos(textContainer[0])
  
  #textContainer.offset({'left': xp + currentOffset.x - currentXPos, 'top': yp + currentOffset.y - currentYPos})

segmentNodes = (node) ->
  for x in node.contents()
    if x.data? and x.data.trim() != '' # text node
      console.log x
      xp = xpos(x)
      yp = ypos(x)
      #xp = $(x).offset().left
      #yp = $(x).offset().top
      
      #console.log xp
      #tagToCreate = '<' + node.prop('tagName').toLowerCase() + '>'
      #if tagToCreate == '<p>'
      #  tagToCreate = '<span>' # why is this necessary? something special block element-wise about the <p>?
      #textContainer = $(tagToCreate) #node.clone() #$('<span>')#$(x.cloneNode(false)) #$('<span>')#node.clone(false)
      textContainer = node.clone(false)
      textContainer.html('')
      textContainer.css(node.getStyleObject())
      #textContainer.css('background-color', '')
      #textContainer.removeChildren()
      #textContainer.show()
      #textContainer.attr('id', 'foo')
      textContainer.css('position', 'absolute')
      #console.log ypos(x)
      #textContainer.append($('<span>&nbsp;</span>'))
      for token in tokenize(x.data, 'en')
        console.log token
        if token == ' '
          textContainer.append($('<span class="ipaspan">').html('&nbsp;'))
        else
          textContainer.append($('<span class="ipaspan">').text(token))
      $(document.documentElement).append(textContainer)
      moveToMatchRange(textContainer, xp, yp)
    else #if $(x).text().trim() != ''
      #console.log x
      segmentNodes($(x))

scaleToMatchWidth = (target, destination) ->
  targetSize = target.width()
  currentSize = destination.width()
  scaleRatio = targetSize / currentSize
  destination.css('-webkit-transform', 'scale(' + scaleRatio + ',1)')
  destination.css('-webkit-transform-origin', 'left')

makeIPAHover = (textBlock) ->
  lineNum = 0
  lang = 'en'
  ipaByDefault = false
  segmentNodes(textBlock)
  
  textBlock.css('opacity', 0)
  
  #return
  
  #textBlock.css('opacity', 0)
  
  for ipaspan,tokenNum in $('.ipaspan')
    $(ipaspan).attr('id', "line#{lineNum}_token#{tokenNum}")
    tokenSpan = $(ipaspan)
    token = $(ipaspan).text()
    #$(ipaspan).css('opacity', 0)
    #$(document.documentElement).append("<span id='line#{lineNum}_token#{tokenNum}'>")
    
    #tokenSpan = $("#line#{lineNum}_token#{tokenNum}")
    tokenSpan.text(token)
    tokenSpan.css('opacity', 100)
    tokenSpan.attr('lang', lang)
    tokenSpan.attr('tokenText', token)
    tokenSpan.attr('lineNum', lineNum)
    tokenSpan.attr('tokenNum', tokenNum)
    tokenSpan.attr('ipaByDefault', ipaByDefault)
    #tokenSpan.css($(ipaspan).getStyleObject())
    #tokenSpan.offset($(ipaspan).offset())
    if ipaByDefault
      showIPA(tokenSpan)
    tokenSpan.mouseenter(() ->
      spanHovered = $(this)
      console.log spanHovered
      if spanHovered.attr('ipaByDefault') == 'true'
        hideIPA(spanHovered)
      else
        showIPA(spanHovered)
    )
    tokenSpan.mouseleave(() ->
      spanHovered = $(this)
      console.log 'mouseleave: ' + spanHovered.text()
      if spanHovered.attr('ipaByDefault') == 'true'
        showIPA(spanHovered)
      else
        hideIPA(spanHovered)
    )
  
  
  
  #$('.ipaspan').hide()

$(document).ready(() ->
  #console.log tokenize('hi guys! how are you?')
  
  #scaleToMatchWidth($('#target'), $('#destination'))
  
  #$('#destination').scaleToMatchTextWidth($('#target'))
  
  #return
  
  makeIPAHover($('body'))
  
  return
  
  for token,tokenNum in tokenize('look what on earth is this byte outofdict', lang)
    $('#display').append("<span id='line#{lineNum}_token#{tokenNum}'>")
    tokenSpan = $("#line#{lineNum}_token#{tokenNum}")
    tokenSpan.text(token)
    tokenSpan.attr('lang', lang)
    tokenSpan.attr('tokenText', token)
    tokenSpan.attr('lineNum', lineNum)
    tokenSpan.attr('tokenNum', tokenNum)
    tokenSpan.attr('ipaByDefault', ipaByDefault)
    if ipaByDefault
      showIPA(tokenSpan)
    tokenSpan.mouseenter(() ->
      spanHovered = $(this)
      if spanHovered.attr('ipaByDefault') == 'true'
        hideIPA(spanHovered)
      else
        showIPA(spanHovered)
    )
    tokenSpan.mouseleave(() ->
      spanHovered = $(this)
      if spanHovered.attr('ipaByDefault') == 'true'
        showIPA(spanHovered)
      else
        hideIPA(spanHovered)
    )
    $('#display').append(' ')
)
