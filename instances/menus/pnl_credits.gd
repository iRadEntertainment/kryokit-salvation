extends PanelContainer


const IRAD_TWITCH = "https://twitch.tv/iraddev"
const IDW_YT = "https://www.youtube.com/iandwynn"
const JERNJAM = "https://itch.io/jam/jern-jam-2026"
const KRIKIT_TWITCH = "https://twitch.tv/krikit_"
const KRIKIT_GAME = "https://s.team/a/4803210"
const PGORLEY_YT = "https://www.youtube.com/watch?v=Hdtal_pHUx4&list=PLcVjSYF-YFMtV_HwMKlaqtvmZXXu-MtVe"


func _on_btn_irad_pressed() -> void: OS.shell_open(IRAD_TWITCH)
func _on_btn_idw_pressed() -> void: OS.shell_open(IDW_YT)
func _on_btn_jernjam_pressed() -> void: OS.shell_open(JERNJAM)
func _on_btn_krikit_pressed() -> void: OS.shell_open(KRIKIT_TWITCH)
func _on_btn_wishlist_pressed() -> void: OS.shell_open(KRIKIT_GAME)
func _on_btn_pgorley_pressed() -> void: OS.shell_open(PGORLEY_YT)
