(($) ->
  $.fn.scaleToMatchTextWidth = (targetElement) ->
    targetWidth = targetElement.textWidth()
    currentWidth = this.textWidth()
    scaleRatio = targetWidth / currentWidth
    this.css('display', 'inline-block')
    this.css('-webkit-transform', 'scale(' + scaleRatio + ',1)')
    this.css('-webkit-transform-origin', 'left')
)(jQuery)
