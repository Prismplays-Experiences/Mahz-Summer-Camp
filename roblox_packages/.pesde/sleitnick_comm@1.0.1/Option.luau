local module = require(script.Parent.Parent["sleitnick_option@1.0.5"]["option"])
export type MatchTable<T> = module.MatchTable<T>
export type MatchFn<T> = module.MatchFn<T>
export type DefaultFn<T> = module.DefaultFn<T>
export type AndThenFn<T> = module.AndThenFn<T>
export type OrElseFn<T> = module.OrElseFn<T>
export type Option<T> = module.Option<T>
return module