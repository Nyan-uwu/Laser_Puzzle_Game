void keyPressed() {
	// Get Mouse Position
	Integer[] arrpos = Mousef.posToArrPos(mouseX, mouseY);
	Vector mpos = new Vector(arrpos[0], arrpos[1]);
	switch(str(key).toLowerCase()) {
		case "q":
			if (Map.tiles[mpos.x][mpos.y].preset == false) {
				switch(Map.tiles[mpos.x][mpos.y].type) {
					case "splitter":
						if (Map.tiles[mpos.x][mpos.y].rotation == 0) Map.tiles[mpos.x][mpos.y].rotation = 1;
						else if (Map.tiles[mpos.x][mpos.y].rotation == 1) Map.tiles[mpos.x][mpos.y].rotation = 0;
						break;
					case "reflector":
						Map.tiles[mpos.x][mpos.y].rotation -= 1;
						if      (Map.tiles[mpos.x][mpos.y].rotation < 0) { Map.tiles[mpos.x][mpos.y].rotation = 3; }
						else if (Map.tiles[mpos.x][mpos.y].rotation > 3) { Map.tiles[mpos.x][mpos.y].rotation = 0; }
						break;
				}
			}
			break;
		case "e":
			if (Map.tiles[mpos.x][mpos.y].preset == false) {
				switch(Map.tiles[mpos.x][mpos.y].type) {
					case "splitter":
						if (Map.tiles[mpos.x][mpos.y].rotation == 0) Map.tiles[mpos.x][mpos.y].rotation = 1;
						else if (Map.tiles[mpos.x][mpos.y].rotation == 1) Map.tiles[mpos.x][mpos.y].rotation = 0;
						break;
					case "reflector":
						Map.tiles[mpos.x][mpos.y].rotation += 1;
						if      (Map.tiles[mpos.x][mpos.y].rotation < 0) { Map.tiles[mpos.x][mpos.y].rotation = 3; }
						else if (Map.tiles[mpos.x][mpos.y].rotation > 3) { Map.tiles[mpos.x][mpos.y].rotation = 0; }
						break;
				}
			}
			break;

		// Switch Block
		case "1":
			App.MAPTILE_SELECTED_TYPE = "block";
			break;
		case "2":
			App.MAPTILE_SELECTED_TYPE = "reflector";
			break;
		case "3":
			App.MAPTILE_SELECTED_TYPE = "splitter";
			break;
	}

	// Calculate Beams
	Map.calculate_beams();
}

void mousePressed() {
	// Get Mouse Position
	Integer[] arrpos = Mousef.posToArrPos(mouseX, mouseY);
	Vector mpos = new Vector(arrpos[0], arrpos[1]);

	switch(mouseButton) {
		case LEFT:
			if (Map.tiles[mpos.x][mpos.y].type == "null") {
				Map.tiles[mpos.x][mpos.y] = new MapTile(new Vector(mpos.x, mpos.y), App.MAPTILE_SELECTED_TYPE);
			}
			else if (Map.tiles[mpos.x][mpos.y].type != "null" && Map.tiles[mpos.x][mpos.y].preset != true) { // Start Dragging Tile
				App.DRAGGING = true;
				App.DRAGGING_MAPTILE = Map.tiles[mpos.x][mpos.y];
				App.DRAGGING_PREVPOS = mpos;
				Map.tiles[mpos.x][mpos.y] = new MapTile(new Vector(mpos.x, mpos.y), "null");
			}
			break;
		case RIGHT:
			if (Map.tiles[mpos.x][mpos.y].type != "null" && Map.tiles[mpos.x][mpos.y].preset != true) {
				Map.tiles[mpos.x][mpos.y] = new MapTile(new Vector(mpos.x, mpos.y), "null");
			}
			break;
	}

	// Calculate Beams
	Map.calculate_beams();
}

void mouseReleased() {
	// Get Mouse Position
	Integer[] arrpos = Mousef.posToArrPos(mouseX, mouseY);
	Vector mpos = new Vector(arrpos[0], arrpos[1]);
	if (App.DRAGGING == true) {
		if (Map.tiles[mpos.x][mpos.y].type == "null") {
			Map.tiles[mpos.x][mpos.y] = App.DRAGGING_MAPTILE;
			Map.tiles[mpos.x][mpos.y].pos = new Vector(mpos.x, mpos.y);
		} else {
			Map.tiles[App.DRAGGING_PREVPOS.x][App.DRAGGING_PREVPOS.y] = App.DRAGGING_MAPTILE;
		}
		App.DRAGGING = false;
		App.DRAGGING_MAPTILE = null;
		App.DRAGGING_PREVPOS = null;

		// Recalculate calculate_beamsAfter Dragging
		Map.calculate_beams();
	}
}

static class Mousef
{
	static Integer[] posToArrPos(Integer x, Integer y) {
		return new Integer[] {floor(x/App.MAPTILE_SIZE.x), floor(y/App.MAPTILE_SIZE.y)};
	}
}

class MousePositionException extends Exception
{
	MousePositionException(String error) { super(error); }
}