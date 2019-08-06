void keyPressed() {
	// Get Mouse Position
	Integer[] arrpos = Mousef.posToArrPos(mouseX, mouseY);
	Vector mpos = new Vector(arrpos[0], arrpos[1]);
	switch(str(key).toLowerCase()) {
		case "q":
			maptile_rotate(mpos, -1);
			break;
		case "e":
			maptile_rotate(mpos,  1);
			break;

		case "p":
			Map.create_preset("custom_map__MYMAP_" + str(second()) + str(minute()) + str(hour()));
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
		case "9":
			App.MAPTILE_SELECTED_TYPE = "beam";
			break;
		case "0":
			App.MAPTILE_SELECTED_TYPE = "sensor";
			break;
	}

	// Calculate Beams
	Map.calculate_beams();
}

void mousePressed() {
	// Get Mouse Position
	Integer[] arrpos = Mousef.posToArrPos(mouseX, mouseY);
	Vector mpos = new Vector(arrpos[0], arrpos[1]);

	if(mpos.x >= 0 && mpos.x < App.MAP_SIZE.x && mpos.y >= 0 && mpos.y < App.MAP_SIZE.y) { switch(mouseButton) {
		case LEFT:
			if (Map.tiles[mpos.x][mpos.y].type == "null") {
				if (Map.blocks.get(App.MAPTILE_SELECTED_TYPE) > 0) { switch(App.MAPTILE_SELECTED_TYPE) {
					case "beam":
						Map.tiles[mpos.x][mpos.y] = new MapTile(new Vector(mpos.x, mpos.y), App.MAPTILE_SELECTED_TYPE);
						Map.blocks.sub(App.MAPTILE_SELECTED_TYPE, 1);
						Map.beams.add(new Vector(mpos.x, mpos.y));
						println(App.MAPTILE_SELECTED_TYPE + ": " + Map.blocks.get(App.MAPTILE_SELECTED_TYPE));
						break;
					case "sensor":
						Map.tiles[mpos.x][mpos.y] = new MapTile(new Vector(mpos.x, mpos.y), App.MAPTILE_SELECTED_TYPE);
						Map.blocks.sub(App.MAPTILE_SELECTED_TYPE, 1);
						Map.sensors.add(new Vector(mpos.x, mpos.y));
						println(App.MAPTILE_SELECTED_TYPE + ": " + Map.blocks.get(App.MAPTILE_SELECTED_TYPE));
						break;
					default:
						Map.tiles[mpos.x][mpos.y] = new MapTile(new Vector(mpos.x, mpos.y), App.MAPTILE_SELECTED_TYPE);
						Map.blocks.sub(App.MAPTILE_SELECTED_TYPE, 1);
						println(App.MAPTILE_SELECTED_TYPE + ": " + Map.blocks.get(App.MAPTILE_SELECTED_TYPE));
						break;
				} }
			}
			else if (Map.tiles[mpos.x][mpos.y].type != "null" && Map.tiles[mpos.x][mpos.y].preset != true) { // Start Dragging Tile
				if (Map.tiles[mpos.x][mpos.y].type == "beam") { for (Integer i = Map.beams.size()-1; i >= 0; i-- ) {
					Vector v = Map.beams.get(i);
					if (v.x == mpos.x && v.y == mpos.y) { Map.beams.remove(v); /*println("REMOVE BEAM");*/ }
				} }
				else if (Map.tiles[mpos.x][mpos.y].type == "sensor") { for (Integer i = Map.sensors.size()-1; i >= 0; i-- ) {
					Vector v = Map.sensors.get(i);
					if (v.x == mpos.x && v.y == mpos.y) { Map.sensors.remove(v); /*println("REMOVE SENSOR");*/ }
				} }
				App.DRAGGING = true;
				App.DRAGGING_MAPTILE = Map.tiles[mpos.x][mpos.y];
				App.DRAGGING_PREVPOS = mpos;
				Map.tiles[mpos.x][mpos.y] = new MapTile(new Vector(mpos.x, mpos.y), "null");
			}
			break;
		case RIGHT:
			if (Map.tiles[mpos.x][mpos.y].type != "null" && Map.tiles[mpos.x][mpos.y].preset != true) { switch(Map.tiles[mpos.x][mpos.y].type) {
				case "beam":
					Map.blocks.add(Map.tiles[mpos.x][mpos.y].type, 1);
					println(Map.tiles[mpos.x][mpos.y].type + ": " + Map.blocks.get(Map.tiles[mpos.x][mpos.y].type));
					Map.tiles[mpos.x][mpos.y] = new MapTile(new Vector(mpos.x, mpos.y), "null");
					for (Integer i = Map.beams.size()-1; i >= 0; i-- ) {
						Vector v = Map.beams.get(i);
						if (v.x == mpos.x && v.y == mpos.y) { Map.beams.remove(v); /*println("REMOVE BEAM");*/ }
					} // println(Map.beams.size());
					break;
				case "sensor":
					Map.blocks.add(Map.tiles[mpos.x][mpos.y].type, 1);
					println(Map.tiles[mpos.x][mpos.y].type + ": " + Map.blocks.get(Map.tiles[mpos.x][mpos.y].type));
					Map.tiles[mpos.x][mpos.y] = new MapTile(new Vector(mpos.x, mpos.y), "null");
					for (Integer i = Map.sensors.size()-1; i >= 0; i-- ) {
						Vector v = Map.sensors.get(i);
						if (v.x == mpos.x && v.y == mpos.y) { Map.sensors.remove(v); /*println("REMOVE SENSOR");*/ }
					} // println(Map.sensors.size());
					break;
				default:
					Map.blocks.add(Map.tiles[mpos.x][mpos.y].type, 1);
					println(Map.tiles[mpos.x][mpos.y].type + ": " + Map.blocks.get(Map.tiles[mpos.x][mpos.y].type));
					Map.tiles[mpos.x][mpos.y] = new MapTile(new Vector(mpos.x, mpos.y), "null");
					break;
			} }
			break;
	} } else if (mouseX >= App.TILETRAY_OFFSET-App.MAPTILE_SIZE.x && mouseX < width) { switch(mouseButton) {
		case LEFT:
			try {
				Integer relpos = ((mouseY+App.TILETRAY_BLOCK_DISTANCE)/App.TILETRAY_BLOCK_DISTANCE)-1;
				String type = App.MAPTILE_AVALIABLE_TYPES[relpos];
				App.MAPTILE_SELECTED_TYPE = type;
				App.DRAGGING              = true;
				App.DRAGGING_FROMTRAY     = true;
				App.DRAGGING_MAPTILE      = new MapTile(new Vector(-1, -1), type);
				App.DRAGGING_PREVPOS      = null;
				println("type: "+type);
			} catch (ArrayIndexOutOfBoundsException e) { println("Invalid TrayTile"); }
			break;
	} }

	// Calculate Beams
	Map.calculate_beams();
}

void mouseReleased() {
	// Get Mouse Position
	Integer[] arrpos = Mousef.posToArrPos(mouseX, mouseY);
	Vector mpos = new Vector(arrpos[0], arrpos[1]);
	if (App.DRAGGING == true) {
		try {
			if (App.DRAGGING_FROMTRAY) {
				if (Map.tiles[mpos.x][mpos.y].type == "null") { switch(App.DRAGGING_MAPTILE.type) {
					case "beam":
						Map.beams.add(new Vector(mpos));
						Map.tiles[mpos.x][mpos.y] = App.DRAGGING_MAPTILE;
						Map.tiles[mpos.x][mpos.y].pos = new Vector(mpos.x, mpos.y);
						break;
					case "sensor":
						Map.sensors.add(new Vector(mpos));
						Map.tiles[mpos.x][mpos.y] = App.DRAGGING_MAPTILE;
						Map.tiles[mpos.x][mpos.y].pos = new Vector(mpos.x, mpos.y);
						break;
					default:
						Map.tiles[mpos.x][mpos.y] = App.DRAGGING_MAPTILE;
						Map.tiles[mpos.x][mpos.y].pos = new Vector(mpos.x, mpos.y);
						break;
				} Map.blocks.sub(App.MAPTILE_SELECTED_TYPE, 1); }
			}
			else if (Map.tiles[mpos.x][mpos.y].type == "null") { switch(App.DRAGGING_MAPTILE.type) {
				case "beam":
					Map.beams.add(new Vector(mpos));
					Map.tiles[mpos.x][mpos.y] = App.DRAGGING_MAPTILE;
					Map.tiles[mpos.x][mpos.y].pos = new Vector(mpos.x, mpos.y);
					break;
				case "sensor":
					Map.sensors.add(new Vector(mpos));
					Map.tiles[mpos.x][mpos.y] = App.DRAGGING_MAPTILE;
					Map.tiles[mpos.x][mpos.y].pos = new Vector(mpos.x, mpos.y);
					break;
				default:
					Map.tiles[mpos.x][mpos.y] = App.DRAGGING_MAPTILE;
					Map.tiles[mpos.x][mpos.y].pos = new Vector(mpos.x, mpos.y);
					break;
			} if (mpos.x == App.DRAGGING_PREVPOS.x && mpos.y == App.DRAGGING_PREVPOS.y) { maptile_rotate(mpos, 1); }
			} else {
				Map.tiles[App.DRAGGING_PREVPOS.x][App.DRAGGING_PREVPOS.y] = App.DRAGGING_MAPTILE;
			}
		} catch (ArrayIndexOutOfBoundsException e) {
			// Map.tiles[App.DRAGGING_PREVPOS.x][App.DRAGGING_PREVPOS.y] = App.DRAGGING_MAPTILE;
			// switch(App.DRAGGING_MAPTILE.type) {
			// 	case "beam":
			// 		Map.beams.add(new Vector(App.DRAGGING_PREVPOS));
			// 		break;
			// 	case "sensor":
			// 		Map.sensors.add(new Vector(App.DRAGGING_PREVPOS));
			// 		break;
			// }
			if (App.DRAGGING_FROMTRAY != true) {
				Map.blocks.add(App.DRAGGING_MAPTILE.type, 1);
				println(App.DRAGGING_MAPTILE.type + ": " + Map.blocks.get(App.DRAGGING_MAPTILE.type));
				Map.tiles[App.DRAGGING_PREVPOS.x][App.DRAGGING_PREVPOS.y] = new MapTile(new Vector(App.DRAGGING_PREVPOS.x, App.DRAGGING_PREVPOS.y), "null");
			} else {

			}
		}
		App.DRAGGING = false;
		App.DRAGGING_FROMTRAY = false;
		App.DRAGGING_MAPTILE = null;
		App.DRAGGING_PREVPOS = null;

		// Recalculate calculate_beamsAfter Dragging
		Map.calculate_beams();
	}
}

void maptile_rotate(Vector mpos, Integer dir) {
	if (dir == 1 || dir == -1) {
		switch(dir) {
			case -1:
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
						case "beam":
							if (Map.tiles[mpos.x][mpos.y].beam_dir.x ==  0 && Map.tiles[mpos.x][mpos.y].beam_dir.y == -1) { Map.tiles[mpos.x][mpos.y].beam_dir = new Vector(-1,  0); }
							else if (Map.tiles[mpos.x][mpos.y].beam_dir.x ==  1 && Map.tiles[mpos.x][mpos.y].beam_dir.y ==  0) { Map.tiles[mpos.x][mpos.y].beam_dir = new Vector( 0, -1); }
							else if (Map.tiles[mpos.x][mpos.y].beam_dir.x ==  0 && Map.tiles[mpos.x][mpos.y].beam_dir.y ==  1) { Map.tiles[mpos.x][mpos.y].beam_dir = new Vector( 1,  0); }
							else if (Map.tiles[mpos.x][mpos.y].beam_dir.x == -1 && Map.tiles[mpos.x][mpos.y].beam_dir.y ==  0) { Map.tiles[mpos.x][mpos.y].beam_dir = new Vector( 0,  1); }
					}
				}
				break;
			case 1:
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
						case "beam":
							if (Map.tiles[mpos.x][mpos.y].beam_dir.x ==  0 && Map.tiles[mpos.x][mpos.y].beam_dir.y == -1) { Map.tiles[mpos.x][mpos.y].beam_dir = new Vector( 1,  0); }
							else if (Map.tiles[mpos.x][mpos.y].beam_dir.x ==  1 && Map.tiles[mpos.x][mpos.y].beam_dir.y ==  0) { Map.tiles[mpos.x][mpos.y].beam_dir = new Vector( 0,  1); }
							else if (Map.tiles[mpos.x][mpos.y].beam_dir.x ==  0 && Map.tiles[mpos.x][mpos.y].beam_dir.y ==  1) { Map.tiles[mpos.x][mpos.y].beam_dir = new Vector(-1,  0); }
							else if (Map.tiles[mpos.x][mpos.y].beam_dir.x == -1 && Map.tiles[mpos.x][mpos.y].beam_dir.y ==  0) { Map.tiles[mpos.x][mpos.y].beam_dir = new Vector( 0, -1); }
					}
				}
				break;
		}
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
