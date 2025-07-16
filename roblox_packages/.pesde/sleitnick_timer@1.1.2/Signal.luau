local module = require(script.Parent.Parent["sleitnick_signal@1.5.0"]["signal"])
export type Connection  = module.Connection 
export type Signal<T...> = module.Signal<T...>
return module