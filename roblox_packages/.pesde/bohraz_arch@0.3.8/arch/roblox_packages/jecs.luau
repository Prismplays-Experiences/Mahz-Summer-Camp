local module = require(script.Parent[".pesde"]["ukendio_jecs@0.5.3"]["jecs"])
export type Archetype  = module.Archetype 
export type Record  = module.Record 
export type Id<T = nil> = module.Id<T >
export type Pair<P, O> = module.Pair<P, O>
export type Entity<T = nil> = module.Entity<T >
export type Query<T...> = module.Query<T...>
export type World  = module.World 
return module