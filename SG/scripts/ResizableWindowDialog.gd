extends WindowDialog

const _INTERACTIVEWIDTH = 15	# Zone dans laquelle le clic déclenche le redimensionnement
const _INTERACTIVEWIDTH2 = 500 # Zone dans laquelle le redimensionnement continue une fois commencé

# Dimensions extrémales de la fenêtre
const _SIZEMINX = 500
const _SIZEMINY = 350
const _SIZEMAXX = 1500
const _SIZEMAXY = 850

var _clickright
var _clickleft
var _clickbottom
var _click = false # Pour empêcher le redimensionnement accidentel en passant au-dessus des bords en cliquer-glisser avec un objet...

func _ready():
	#### Curseur modifié pour la croix de ferrmeture de la fenêtre ####
	get_children()[0].set_default_cursor_shape(2)

	set_process(true)

func _process(delta):
	var mouse_pos = get_local_mouse_pos()
	var global_mouse_pos = get_global_mouse_pos()
	var size = get_size()

	#### Curseurs spéciaux pour le redimensionnement ####
	if mouse_pos.y > 0:	#pour que les curseurs modifiés ne s'affichent pas sur la barre de titre
		if !_click:
			if abs(mouse_pos.x - get_size().x) < _INTERACTIVEWIDTH or abs(mouse_pos.x) < _INTERACTIVEWIDTH:
				set_default_cursor_shape(10)
			elif abs(mouse_pos.y - size.y) < _INTERACTIVEWIDTH:
				set_default_cursor_shape(9)
			else:
				set_default_cursor_shape(0)

	#### Input ####
	if !(Input.is_mouse_button_pressed(BUTTON_LEFT)): # Rien
		_clickright = false
		_clickleft = false
		_clickbottom = false
		_click = false

	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		if !_click:
			_click = true
			if abs(mouse_pos.x - size.x) < _INTERACTIVEWIDTH and mouse_pos.y > 0 and mouse_pos.y < get_size().y: # Droite
				set_default_cursor_shape(10)
				_clickright = true
				_clickleft = false
				_clickbottom = false

			if abs(mouse_pos.x) < _INTERACTIVEWIDTH and mouse_pos.y > 0 and mouse_pos.y < get_size().y: # Gauche
				set_default_cursor_shape(10)
				_clickleft = true
				_clickright = false
				_clickbottom = false

			if abs(mouse_pos.y - size.y) < _INTERACTIVEWIDTH and mouse_pos.x > 0 and mouse_pos.x < get_size().x: # Bas
				set_default_cursor_shape(9)
				_clickbottom = true
				_clickright = false
				_clickleft = false
	####################

	#### Redimensionnement ####
	if _clickright:
		if abs(mouse_pos.x - size.x) < _INTERACTIVEWIDTH2 :
			if mouse_pos.x-size.x < 0 and size.x < _SIZEMINX: # Réduction quand la largeur est plus petite que le minimum
				pass
			elif mouse_pos.x-size.x > 0 and size.x > _SIZEMAXX: # Agrandissement quand la largeur est plus grande que le maximum
				pass
			else: # Agrandissement ou réduction quand la largeur est plus petite que le maximum et plus grande que le minimum
				set_size(size + Vector2(mouse_pos.x-size.x, 0))

			_resizeChildren()

	if _clickleft:
		if abs(mouse_pos.x) < _INTERACTIVEWIDTH2:
			if mouse_pos.x < 0 and size.x < _SIZEMINX : # Agrandissement quand la largeur est plus petite que le minimum
				var previousRightPosition = get_pos().x + get_size().x
				set_size(size - Vector2(mouse_pos.x, 0))
				var newSize = get_size().x
				set_pos(Vector2(previousRightPosition-newSize, get_pos().y))
			elif mouse_pos.x> 0 and size.x < _SIZEMINX : # Réduction quand la largeur est plus petite que le minimum
				pass
			elif mouse_pos.x< 0 and size.x > _SIZEMAXX : # Agrandissement quand la largeur est plus grande que le maximum
				pass
			else : # Agrandissement quand la largeur est plus petite que le minimum
				if abs(mouse_pos.x) > 5:	# Pour qu'il n'y ait pas de saut quand on clique sans redimensionner
					var previousRightPosition = get_pos().x + get_size().x
					set_size(size - Vector2(mouse_pos.x, 0))
					var newSize = get_size().x
					set_pos(Vector2(previousRightPosition-newSize, get_pos().y))

			_resizeChildren()

	if _clickbottom:
		if abs(mouse_pos.y - size.y) < _INTERACTIVEWIDTH2:
			if mouse_pos.y-size.y > 0 and size.y < _SIZEMINY : # Agrandissement quand la hauteur est plus petite que le minimum
				set_size(size + Vector2(0, mouse_pos.y-size.y))
			elif mouse_pos.y-size.y < 0 and size.y < _SIZEMINY : # Réduction quand la hauteur est plus petite que le minimum
				pass
			elif mouse_pos.y-size.y > 0 and size.y > _SIZEMAXY : # Agrandissement quand la hauteur est plus grande que le maximum
				pass
			else: # Agrandissement quand la hauteur est plus petite que le maximum et plus grande que le minimum
				set_size(size + Vector2(0, mouse_pos.y-size.y))

			_resizeChildren()

#### Redimensionne tous les enfants de la fenêtre pour qu'ils occupent toute la fenêtre sauf une marge ####
func _resizeChildren():
	if get_children().size() > 1:	#pour ne pas redimensionner la croix de fermeture de la fenêtre avec le reste
		for i in range(1, get_children().size()): # l'enfant 0 est la croix de fermeture de la fenêtre
			var child = get_children()[i]
			child.set_size(get_size() - Vector2(20,10))
####################