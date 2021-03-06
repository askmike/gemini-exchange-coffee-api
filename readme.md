## Intro

This is a node.js wrapper for the gemini cryptocurrency exchange. Github link here https://github.com/KevTheRev13/gemini-exchange-coffee-api

I used coffeescript (http://coffeescript.org/) as a starting point for learning javascript. Coffeescript is a cleaner and more organized script that compiles into JS. 

When you npm install this package, the gemini.coffee source file is hidden. It does "not" run coffee compile upon npm install, so should you choose to get the sourcecode from Github and modify the gemini.coffee source file - you will need to re-compile it into js manually.

### Gemini Sandbox
If you would like to connect to the sandbox, change the api url located in gemini.js (or gemini.coffee if you plan to re-run the coffee compile).

Change this line:
this.url = "https://api.gemini.com";
to this line:
this.url = "https://api.sandbox.gemini.com";

### Install

`npm install gemini-exchange-coffee-api`

### Error

If you're getting the error `[Error: Nonce is too small.]` then your most likely
running the same process twice using the same API keys.

- error was unreproducible for me, kept here from prior fork just in case.

## Supported API Calls

	orderbook: (symbol, options, cb)
	trades: (symbol, cb)
	ticker: (symbol, cb)
	get_symbols: (cb)
	symbols_details: (cb)
	wallet_balances: (cb)
	new_order: (symbol, amount, price, exchange, side, type, cb)
	cancel_order: (order_id, cb)
	cancel_all_orders: (cb)
	order_status: (order_id, cb)
	active_orders: (cb)
	account_infos: (cb)
