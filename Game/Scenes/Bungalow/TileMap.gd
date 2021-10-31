"""
Based on https://escada-games.itch.io/randungeon/devlog/261991/how-to-use-godots-astar2d-for-path-finding
"""
extends TileMap
var aStar:AStar2D
var aSolidCells = []
func getAStarCellId(vCell:Vector2)->int:return int(vCell.y+vCell.x*self.get_used_rect().size.y)
func _ready()->void:
	 aStarStart()
func aStarStart()->void:
	 var size=self.get_used_rect().size
	 aStar=AStar2D.new()
	 aStar.reserve_space(size.x * size.y)
	 # Creates AStar grid
	 for i in size.x:
		 for j in size.y:
			 var idx=getAStarCellId(Vector2(i,j))
			 aStar.add_point(idx, map_to_world(Vector2(i,j)))
	 # Fills AStar grid with info about valid tiles
	 for i in size.x:
		 for j in size.y:
			 if get_cellv(Vector2(i,j))!=-1:
				 var idx=getAStarCellId(Vector2(i,j))
				 for vNeighborCell in [Vector2(i,j-1),Vector2(i,j+1),Vector2(i-1,j),Vector2(i+1,j)]:
					 var idxNeighbor=getAStarCellId(vNeighborCell)
					 if aStar.has_point(idxNeighbor) and not vNeighborCell in aSolidCells:
						 aStar.connect_points(idx, idxNeighbor, false)

func occupyAStarCell(vGlobalPosition:Vector2)->void:
	 var vCell:=self.world_to_map(vGlobalPosition)
	 var idx:=getAStarCellId(vCell)
	 if aStar.has_point(idx):aStar.set_point_disabled(idx, true)

func freeAStarCell(vGlobalPosition:Vector2)->void:
	 var vCell:=self.world_to_map(vGlobalPosition)
	 var idx:=getAStarCellId(vCell)
	 if aStar.has_point(idx):aStar.set_point_disabled(idx, false)

# Function called whenever
# the player finishes their turn
func act(entity)->void:
	if entity: 
		# This variable holds an array
		# with the path towards the player.
		var path=self.getAStarPath(self.global_position, entity.global_position)
		if path.size() > 2:
			# This isn't important for now...
			path.pop_front()
			var vTarget=path.pop_front()
			vTarget.x=16*int(vTarget.x/16)+8; vTarget.y=16*int(vTarget.y/16)+8 # Fixes the target position since I coded the grid in a bad way
			# Here is the important stuff!
			#self.freeAStarGrid(self.global_position)
			#self.occupyAStarGrid(vTarget)
			# $animationPlayer.play("animationActorMoving")
			entity.moveTo(vTarget)
		else:
			# This "if" checks if the enemy
			# is right next to the player,
			#so that it can attack
			#	 if tilemapAStar.are_points_connected(global.tilemap.getAStarWorldVectorId(self.global_position),global.tilemap.getAStarWorldVectorId(global.player.global_position)):
			#		 self.attack()
			pass
		
func getAStarPath(vStartPosition:Vector2,vTargetPosition:Vector2)->Array:
	 var vCellStart = world_to_map(vStartPosition)
	 var idxStart=getAStarCellId(vCellStart)
	 var vCellTarget = world_to_map(vTargetPosition)
	 var idxTarget=getAStarCellId(vCellTarget)
	 # Just a small check to see if both points are in the grid
	 if aStar.has_point(idxStart) and aStar.has_point(idxTarget):
		 return Array(aStar.get_point_path(idxStart, idxTarget))
	 return []
