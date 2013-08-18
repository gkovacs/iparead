express = require 'express'
app = express()
http = require 'http'
httpserver = http.createServer(app)
httport = process.env.PORT ? 5000
httpserver.listen(httport, '0.0.0.0')
webRoot = 'http://ipakaraoke.herokuapp.com/'

getprononciation = require './getprononciation'

app.configure('development', () ->
  app.use(express.errorHandler())
)

app.configure( ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'ejs')
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.set('view options', { layout: false })
  app.locals({ layout: false })
  app.use(express.static(__dirname + '/'))
)

app.get '/getIPA', (req, res) ->
  console.log req
  lang = req.query.lang
  word = req.query.word
  
  getprononciation.getIPARateLimitedCached(word, (ipa_pronunc) ->
    res.send ipa_pronunc
  )
  #res.send lang
  #res.send req.toString()
