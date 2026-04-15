extends Control

var health = 100
var coins = 0

func update_health(value):
    health = value
    $HealthLabel.text = "Health: " + str(health)

func add_coin():
    coins += 1
    $CoinsLabel.text = "Coins: " + str(coins)
