extends Resource
class_name CardHand

## The corresponding [LobbyMember.id] of this CardHand.[br]
## 0 means assigned to game
var associated_id: int = -1

var cards: Dictionary[int, Card] = {
	0: null,
	1: null,
	2: null,
}


## Switches the card of one [class CardHand] with another
func switch_cards(other: CardHand, self_index: int, other_index: int) -> void:
	var self_card: Card = self.cards.get(self_index)
	var other_card: Card = other.cards.get(other_index)
	self.cards.set(self_index, other_card)
	other.cards.set(other_index, self_card)


func _to_string() -> String:
	var string: String = ""
	for key: int in cards.keys():
		var card: Card = cards.get(key)
		if card: string += "card%d(%s) " % [key, card.to_string()]
	return string
