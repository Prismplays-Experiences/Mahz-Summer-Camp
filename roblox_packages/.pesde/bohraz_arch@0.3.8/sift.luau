local module = require(script.Parent.Parent["csqrl_sift@0.0.8"]["sift"])
export type Dictionary<K, V> = module.Dictionary<K, V>
export type Array<T> = module.Array<T>
export type List<T> = module.List<T>
export type Set<T> = module.Set<T>
return module