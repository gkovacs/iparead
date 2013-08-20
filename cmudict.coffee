root = exports ? this

fs = require 'fs'

arpabet_to_ipa = {}

for line in fs.readFileSync('Arpabet-to-IPA.txt', 'utf-8').split('\n')
  line = line.trim()
  if line.length == 0
    continue
  [arpabet,ipa,htmlcode] = line.split(',')
  arpabet_to_ipa[arpabet] = ipa

isLetter = (letter) ->
  return ('A' <= letter <= 'Z' || 'a' <= letter <= 'z')

toIPALetter = (arpabetLetter) ->
  if not arpabetLetter?
    throw 'not valid arpabetLetter: ' + arpabetLetter
  ipaLetter = arpabet_to_ipa[arpabetLetter]
  if not ipaLetter?
    ipaLetter = arpabet_to_ipa[arpabetLetter[...-1]]
    if not ipaLetter?
      throw 'not valid arpabetLetter: ' + arpabetLetter
  return ipaLetter

root.ipa_lookup_en = {}

for line in fs.readFileSync('cmudict.0.7a.txt', 'utf-8').split('\n')
  line = line.trim()
  if not isLetter(line[0]) # commented out
    continue
  [word,arpabet] = line.split('  ')
  if not isLetter(word[-1..-1][0]) # does not end with a letter, alternative pronunciation
    continue
  ipa = (toIPALetter(x) for x in arpabet.split(' ')).join('')
  #console.log word
  #console.log arpabet
  #console.log ipa
  root.ipa_lookup_en[word.trim().toLowerCase()] = ipa

root.getIPA = (word) ->
  return root.ipa_lookup_en[word.trim().toLowerCase()]

main = () ->
  console.log 'ipadict_en = ' + JSON.stringify(root.ipa_lookup_en)

main() if require.main is module

