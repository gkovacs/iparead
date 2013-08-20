root = exports ? this

root.getIPA = (word, lang, callback) ->
  callback(root.ipadict_en[word.trim().toLowerCase()])

#getIPA = root.getIPA = (word, lang, callback) ->
#  $.get('/getIPA?' + $.param({'lang': lang, 'word': word}), (ipa_pronunc) ->
#    console.log ipa_pronunc
#    callback(ipa_pronunc)
#  )

