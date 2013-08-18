root = exports ? this
print = console.log

sys = require 'util'
fs = require 'fs'
http_get = require 'http-get'

$ = require 'jQuery'
redis = require 'redis'
client = redis.createClient()

getPrononciation = (text, callback) ->
  http_get.get({url: 'http://dictionary.reference.com/browse/' + text}, (err, dlData) ->
    buffer = dlData.buffer
    prononc = buffer[buffer.indexOf('<span class="show_spellpr"')..]
    pronstart = '<span class="prondelim">[</span>'
    pronend = '<span class="prondelim">]</span>'
    prononc = prononc[prononc.indexOf(pronstart)+pronstart.length...prononc.indexOf(pronend)]
    prurlstart = '<span class="speaker" audio="'
    prurl = buffer[buffer.indexOf(prurlstart)+prurlstart.length..]
    prurl = prurl[...prurl.indexOf('"')]
    
    ipa_prononc = buffer[buffer.indexOf('<span class="show_spellpr')..]
    ipa_pronstart = '<span class="prondelim">/</span><span class="pron">'
    ipa_pronend = '</span><span class="prondelim">'
    ipa_prononc = ipa_prononc[ipa_prononc.indexOf(ipa_pronstart)+ipa_pronstart.length...ipa_prononc.indexOf(ipa_pronend)]
    
    client.set('ipa_en|' + text, ipa_prononc)
    client.set('engprn|' + text, prononc + '|' + prurl)
    callback(text, prononc, prurl)
  )

fixIPA = (reply) ->
  return $('<span>').html(reply).text().split(';')[0].split(',')[0].split('stressed')[-1..-1][0]

getIPA = (text, callback) ->
  http_get.get({url: 'http://dictionary.reference.com/browse/' + text}, (err, dlData) ->
    buffer = dlData.buffer
    prononc = buffer[buffer.indexOf('<span class="show_spellpr"')..]
    pronstart = '<span class="prondelim">[</span>'
    pronend = '<span class="prondelim">]</span>'
    prononc = prononc[prononc.indexOf(pronstart)+pronstart.length...prononc.indexOf(pronend)]
    prurlstart = '<span class="speaker" audio="'
    prurl = buffer[buffer.indexOf(prurlstart)+prurlstart.length..]
    prurl = prurl[...prurl.indexOf('"')]
    
    ipa_prononc = buffer[buffer.indexOf('<span class="show_ipapr')..]
    ipa_pronstart = '<span class="prondelim">/</span><span class="pron">'
    ipa_pronend = '</span><span class="prondelim">'
    ipa_prononc = ipa_prononc[ipa_prononc.indexOf(ipa_pronstart)+ipa_pronstart.length...ipa_prononc.indexOf(ipa_pronend)]
    
    console.log 'ipa_en is set to: ' + ipa_prononc
    
    client.set('ipa_en|' + text, ipa_prononc)
    client.set('engprn|' + text, prononc + '|' + prurl)
    
    callback(fixIPA(ipa_prononc))
  )

lastPrononciationFetchTimestamp = 0

getPrononciationRateLimited = (text, callback) ->
  timestamp = Math.round((new Date()).getTime() / 1000)
  if lastPrononciationFetchTimestamp + 1 >= timestamp
    setTimeout(() ->
      getPrononciationRateLimited(text, callback)
    , 1000)
  else
    lastPrononciationFetchTimestamp = timestamp
    getPrononciation(text, callback)

getIPARateLimited = (text, callback) ->
  console.log 'calling getIPARateLimited for ' + text
  timestamp = Math.round((new Date()).getTime() / 1000)
  if lastPrononciationFetchTimestamp + 1 >= timestamp
    setTimeout(() ->
      getIPARateLimited(text, callback)
    , 1000)
  else
    lastPrononciationFetchTimestamp = timestamp
    getIPA(text, callback)

getPrononciationRateLimitedCached = (text, callback) ->
  client.get('engprn|' + text, (err, reply) ->
    if reply?
      prononc = reply[...reply.lastIndexOf('|')]
      prurl = reply[reply.lastIndexOf('|')+1..]
      callback(text, prononc, prurl)
    else
      getPrononciationRateLimited(text, callback)
  )

getIPARateLimitedCached = (text, callback) ->
  client.get('ipa_en|' + text, (err, reply) ->
    if reply?
      callback(fixIPA(reply))
    else
      getIPARateLimited(text, callback)
  )

#root.getPrononciation = getPrononciation
root.getPrononciationRateLimitedCached = getPrononciationRateLimitedCached
root.getIPARateLimitedCached = getIPARateLimitedCached
root.getIPARateLimited = getIPARateLimited

main = ->
  text = process.argv[2]
  print text
  getPrononciationRateLimitedCached(text, (ntext, prononc, purl) ->
    print prononc
    print purl
  )

main() if require.main is module
