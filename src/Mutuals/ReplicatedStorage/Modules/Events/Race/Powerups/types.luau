export type Powerup = {
	Activate: (self: Powerup, player: Player, targetPlayer: Player?) -> boolean,
}

return {}