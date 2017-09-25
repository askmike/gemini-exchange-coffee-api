# IMPORTANT: If you modify this file, you must recompile it with the coffee command 
# "coffee --bare --compile --output lib src" . The precompile option was inconsistent, and this
# is a manual workaround.

# process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

request = require 'request'
crypto = require 'crypto'
qs = require 'querystring'

module.exports = class Gemini

	constructor: (key, secret, nonceGenerator) ->

		@url = "https://api.gemini.com"
		@version = 'v1'
		@key = key
		@secret = secret
		@nonce = new Date().getTime()
		@_nonce = if typeof nonceGenerator is "function" then nonceGenerator else () -> return ++@nonce

	make_request: (sub_path, params, cb) ->

		if !@key or !@secret
			return cb(new Error("missing api key or secret"))

		path = '/' + @version + '/' + sub_path
		url = @url + path
		nonce = JSON.stringify(@_nonce())

		payload = 
			request: path
			nonce: nonce

		for key, value of params
			payload[key] = value

		payload = new Buffer(JSON.stringify(payload)).toString('base64')
		signature = crypto.createHmac("sha384", @secret).update(payload).digest('hex')

		headers = 
			'X-GEMINI-APIKEY': @key
			'X-GEMINI-PAYLOAD': payload
			'X-GEMINI-SIGNATURE': signature

		request { url: url, method: "POST", headers: headers, timeout: 15000 }, (err,response,body)->
			
			if err || (response.statusCode != 200 && response.statusCode != 400)
				return cb new Error(err ? response.statusCode)
				
			try
				result = JSON.parse(body)
			catch error
				return cb(null, { message : body.toString() } )
			
			if result.message?
				return cb new Error(result.message)

			cb null, result
	
	make_public_request: (path, cb) ->

		url = @url + '/v1/' + path  

		request { url: url, method: "GET", timeout: 15000}, (err,response,body)->
			
			if err || (response.statusCode != 200 && response.statusCode != 400)
				return cb new Error(err ? response.statusCode)
			
			try
				result = JSON.parse(body)
			catch error
				return cb(null, { message : body.toString() } )

			if result.message?
				return cb new Error(result.message)
			
			cb null, result
	
	#####################################
	########## PUBLIC REQUESTS ##########
	#####################################                            

	orderbook: (symbol, options, cb) ->

		index = 0
		uri = 'book/' + symbol 

		if typeof options is 'function'
			cb = options
		else 
			try 
				for option, value of options
					if index++ > 0
						query_string += '&' + option + '=' + value
					else
						query_string = '/?' + option + '=' + value

				if index > 0 
					uri += query_string
			catch err
				return cb(err)

		@make_public_request(uri, cb)
	
	trades: (symbol, cb) ->

		@make_public_request('trades/' + symbol, cb)

	ticker: (symbol, cb) ->

		@make_public_request('pubticker/' + symbol, cb)

	get_symbols: (cb) ->

		@make_public_request('symbols', cb)

	symbols_details: (cb) ->

		@make_public_request('symbols_details', cb)

	# #####################################
	# ###### AUTHENTICATED REQUESTS #######
	# #####################################   

	wallet_balances: (cb) ->

		@make_request('balances', cb)

	new_order: (symbol, amount, price, exchange, side, type, cb) ->

		params = 
			symbol: symbol
			amount: amount
			price: price
			exchange: exchange
			side: side
			type: type

		@make_request('order/new', params, cb)  

	cancel_order: (order_id, cb) ->

		params = 
			order_id: parseInt(order_id)

		@make_request('order/cancel', params, cb)

	cancel_all_orders: (cb) ->

		@make_request('order/cancel/all', {}, cb)

	order_status: (order_id, cb) ->

		params = 
			order_id: order_id

		@make_request('order/status', params, cb)  

	active_orders: (cb) ->

		@make_request('orders', {}, cb) 

	account_infos: (cb) ->

		@make_request('account_infos', {}, cb)
