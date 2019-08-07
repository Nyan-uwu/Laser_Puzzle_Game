void setup() {
	size(751, 651);
	// Init Application
	Vector app_size     = new Vector(width, height);
	Vector window_size  = new Vector(width-151, height-1);
	Vector map_size     = new Vector(25, 25);
	Vector maptile_size = new Vector(floor(window_size.x/map_size.x), floor(window_size.y/map_size.y));
	App.init(app_size, window_size, map_size, maptile_size);
	// Init Classes
	Renderer = new Renderer();
	Map      = new Map(map_size);

	// Initial Calculation
	Map.calculate_beams();
}
void draw() { background(0); Renderer.render_all(); } /* Run Final Frame Render */

class Map
{

	MapTile[][] tiles;
	ArrayList<Vector> beams;
	ArrayList<Vector> sensors;

	IntDict blocks = null;

	String preset_loaded = "custom";

	Map(Vector map_size) {
		this.tiles = new MapTile[map_size.x][map_size.y]; // Create Tiles
		this.beams = new ArrayList<Vector>();
		this.sensors = new ArrayList<Vector>();

		this.load_preset(threebitcalc, threebitcalc_blocks); // Load Preset

		for (String b : this.blocks.keyArray()) { println(b, blocks.get(b)); }
	}

	void create_preset(String name) {
		String output = "MapTile[] " + name + " = {";
		for (MapTile[] arr : this.tiles) {
			for (MapTile mt : arr) {
				if (mt.type != "null") { switch(mt.type) {
					case "reflector":
						output += "new MapTile(new Vector(" + mt.pos.x + "," + mt.pos.y + "), \"" + mt.type + "\", " + mt.rotation + "),";
						break;
					case "and":
						output += "new MapTile(new Vector(" + mt.pos.x + "," + mt.pos.y + "), \"" + mt.type + "\", " + mt.rotation + "),";
						break;
					case "or":
						output += "new MapTile(new Vector(" + mt.pos.x + "," + mt.pos.y + "), \"" + mt.type + "\", " + mt.rotation + "),";
						break;
					case "xor":
						output += "new MapTile(new Vector(" + mt.pos.x + "," + mt.pos.y + "), \"" + mt.type + "\", " + mt.rotation + "),";
						break;
					case "splitter":
						output += "new MapTile(new Vector(" + mt.pos.x + "," + mt.pos.y + "), \"" + mt.type + "\", " + mt.rotation + "),";
						break;
					case "beam":
						output += "new MapTile(new Vector(" + mt.pos.x + "," + mt.pos.y + "), \"" + mt.type + "\", new Vector(" + mt.beam_dir.x + "," + mt.beam_dir.y + ")),";
						break;
					case "sensor":
						output += "new MapTile(new Vector(" + mt.pos.x + "," + mt.pos.y + "), \"" + mt.type + "\", " + mt.dstate + "),";
						break;
					default:
						output += "new MapTile(new Vector(" + mt.pos.x + "," + mt.pos.y + "), \"" + mt.type + "\"),";
						break;
				} }
			}
		}
		if (output.charAt(output.length()-1) == ',') {
			println("Removed ,");
			output = output.substring(0, output.length()-1);
		} output += "};";
		println("Creation Completed.\n" + output);
	}

	void load_preset(String preset) {
		if (preset != null) {
			this.preset_loaded = preset;
			MapPreset mp = new MapPreset();
			MapTile[] presetarr = null;
			IntDict blocks = null;
			// Load Preset
			switch(preset) {
				case "preset__basic_map":
					presetarr = mp.preset__basic_map;
					blocks    = mp.preset__basic_map_blocks;
					break;
				case "$level__1":
					presetarr = base__level__1;
					blocks    = base__level__1_blocks;
					break;
				case "$level__2":
					presetarr = base__level__2;
					blocks    = base__level__2_blocks;
					break;
				case "$level__3":
					presetarr = base__level__3;
					blocks    = base__level__3_blocks;
					break;
				case "$level__4":
					presetarr = base__level__4;
					blocks    = base__level__4_blocks;
					break;
			}
			this.load_preset(presetarr, blocks);
		}

	}
	void load_preset(MapTile[] mta, IntDict blocksleft) {

		if (blocksleft != null) {
			this.blocks = blocksleft;
		} else {
			this.blocks = new IntDict();
			this.blocks.set("block", 99);
			this.blocks.set("reflector", 99);
			this.blocks.set("splitter", 99);
			this.blocks.set("beam", 99);
			this.blocks.set("sensor", 99);
		}

		for (Integer i = 0; i < this.tiles.length; i++) { // Populate Map With Tiles
			for (Integer j = 0; j < this.tiles[i].length; j++) {
				this.tiles[i][j] = new MapTile(new Vector(i, j), "null");
			}
		}

		if (mta != null) {
			// Import Preset
			for (MapTile mt : mta) {
				this.tiles[mt.pos.x][mt.pos.y] = mt;
				this.tiles[mt.pos.x][mt.pos.y].preset = true;
			}

			// Find Beams && Sensors
			this.beams = new ArrayList<Vector>();
			this.sensors = new ArrayList<Vector>();
			for (MapTile[] arr : this.tiles) {
				for (MapTile mt : arr) {
					if (mt.type == "beam") { this.beams.add(new Vector(mt.pos.x, mt.pos.y)); println("Beam Found @ " + mt.pos.x + ":" + mt.pos.y); }
					if (mt.type == "sensor") { this.sensors.add(new Vector(mt.pos.x, mt.pos.y)); println("Sensor Found @ " + mt.pos.x + ":" + mt.pos.y); }
				}
			}

			println("Preset Has Been Loaded");
		} else {
			println("Preset Does Not Exist.");
		}
	}

	void calculate_beams() { calculate_beams(true); }
	void calculate_beams(Boolean firstRun) {
		if (firstRun == true) {
			for (MapTile[] arr : this.tiles) { for (MapTile mt : arr) { mt.laserCount = 0; } }
			for (MapTile[] arr : this.tiles) { for (MapTile mt : arr) { mt.hit = false;    } }
			for (Vector b : this.beams)   { this.tiles[b.x][b.y].fire();      }
		}
		for (MapTile[] arr : this.tiles) { for (MapTile mt : arr) { if (Map.tiles[mt.pos.x][mt.pos.y].type == "xor") { if (Map.tiles[mt.pos.x][mt.pos.y].laserCount == 1) {
			try {
				println("Map.tiles[mt.pos.x][mt.pos.y].laserCount: "+Map.tiles[mt.pos.x][mt.pos.y].laserCount);
				switch(Map.tiles[mt.pos.x][mt.pos.y].rotation) {
					case 0:
						if (mt.pos.y - 1 < 0) { throw new ArrayIndexOutOfBoundsException("Beam Out Of Bounds"); }
						mt.fire(false, new Vector(mt.pos), new Vector( 0, -1));
						break;
					case 1:
						if (mt.pos.x + 1 >= App.MAP_SIZE.x) { throw new ArrayIndexOutOfBoundsException("Beam Out Of Bounds"); }
						mt.fire(false, new Vector(mt.pos), new Vector( 1, 0 ));
						break;
					case 2:
						if (mt.pos.y + 1 >= App.MAP_SIZE.y) { throw new ArrayIndexOutOfBoundsException("Beam Out Of Bounds"); }
						mt.fire(false, new Vector(mt.pos), new Vector( 0, 1 ));
						break;
					case 3:
						if (mt.pos.x - 1 < 0) { throw new ArrayIndexOutOfBoundsException("Beam Out Of Bounds"); }
						mt.fire(false, new Vector(mt.pos), new Vector(-1, 0 ));
						break;
				}
			} catch (ArrayIndexOutOfBoundsException e) { }
		} else { Map.tiles[mt.pos.x][mt.pos.y].beam_body = new ArrayList<Vector>(); } } } }

		Boolean missed = false;
		for (Vector s : this.sensors) { if (this.tiles[s.x][s.y].hit == this.tiles[s.x][s.y].dstate) { missed = true; } }
		if (!missed) {
			println("Level Completed!");
			App.LEVEL_DISPLAY_BUTTON = true;
		} else {
			App.LEVEL_DISPLAY_BUTTON = false;
		}
	}

	void next_level() {
		App.LEVEL_DISPLAY_BUTTON = false;
		switch(Map.preset_loaded) {
			case "$level__1":
				Map.load_preset("$level__2");
				break;
			case "$level__2":
				Map.load_preset("$level__3");
				break;
			case "$level__3":
				Map.load_preset("$level__4");
				break;
			// case "$level__4":
			// 	Map.load_preset(base__level__5, base__level__5_blocks);
			// 	break;
		}
		calculate_beams();
	}

	void render_levelbutton() {
		fill(200); stroke(255); strokeWeight(1);
		rect(App.TILETRAY_OFFSET-App.MAPTILE_SIZE.x*1.5, height-App.MAPTILE_SIZE.y*1.5, App.MAPTILE_SIZE.x*3, App.MAPTILE_SIZE.y);
		fill(0); stroke(0); textSize(16); textAlign(CENTER);
		text("Next Level", App.TILETRAY_OFFSET, height-App.MAPTILE_SIZE.y*1.5+App.MAPTILE_SIZE.y/2+5);
	}

	void render_background() {
		for (MapTile[] arr : this.tiles) {
			for (MapTile mt : arr) {
				noFill(); stroke(255, 150); strokeWeight(1);
				rect(mt.pos.x*App.MAPTILE_SIZE.x, mt.pos.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
			}
		}
	}

	void render_tiles() {
		for (Vector b : this.beams) {
			this.tiles[b.x][b.y].render_beam();
		}
		for (MapTile[] arr : this.tiles) {
			for (MapTile mt : arr) {
				if (mt.type == "xor") { mt.render_beam(); }
				mt.render();
			}
		}
	}

	void render_dragtile() {
		// Get Mouse Position
		Integer[] arrpos = Mousef.posToArrPos(mouseX, mouseY);
		Vector mpos = new Vector(arrpos[0], arrpos[1]); // println("mpos.x : mpos.y: "+mpos.x+":"+mpos.y);
		if (mpos.x >= 0 && mpos.x < App.MAP_SIZE.x && mpos.y >= 0 && mpos.y < App.MAP_SIZE.y) {
			fill(255); stroke(255); strokeWeight(3);
			line(mpos.x*App.MAPTILE_SIZE.x, mpos.y*App.MAPTILE_SIZE.y, mpos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/3, mpos.y*App.MAPTILE_SIZE.y);
			line(mpos.x*App.MAPTILE_SIZE.x, mpos.y*App.MAPTILE_SIZE.y, mpos.x*App.MAPTILE_SIZE.x, mpos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/3);

			line(mpos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, mpos.y*App.MAPTILE_SIZE.y, mpos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x-App.MAPTILE_SIZE.x/3, mpos.y*App.MAPTILE_SIZE.y);
			line(mpos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, mpos.y*App.MAPTILE_SIZE.y, mpos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, mpos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/3);

			line(mpos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, mpos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y, mpos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x-App.MAPTILE_SIZE.x/3, mpos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y);
			line(mpos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, mpos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y, mpos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, mpos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y-App.MAPTILE_SIZE.y/3);

			line(mpos.x*App.MAPTILE_SIZE.x, mpos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y, mpos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/3, mpos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y);
			line(mpos.x*App.MAPTILE_SIZE.x, mpos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y, mpos.x*App.MAPTILE_SIZE.x, mpos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y-App.MAPTILE_SIZE.y/3);
		}
	}

	void render_tiletray() {
		// println("App.TILETRAY_OFFSET: "+App.TILETRAY_OFFSET);
		Integer offset = App.TILETRAY_OFFSET;
		Integer j = App.MAPTILE_SIZE.y;
		for (String type :  App.MAPTILE_AVALIABLE_TYPES) {
			fill(255); stroke(255); strokeWeight(1); textSize(14); textAlign(CENTER);
			text(type, offset, j-5);
			switch(type) {
				case "block":
					if (Map.blocks.get(type) > 0) {
						fill(255); stroke(255); strokeWeight(1);
					} else {
						fill(255, 50); stroke(255, 50); strokeWeight(1);
					}
					text(Map.blocks.get(type), offset+App.MAPTILE_SIZE.x, j+App.MAPTILE_SIZE.y);
					rect(offset-(App.MAPTILE_SIZE.x/2), j, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
					break;
				case "reflector":
					if (Map.blocks.get(type) > 0) {
						fill(255); stroke(255); strokeWeight(1);
					} else {
						fill(255, 50); stroke(255, 50); strokeWeight(1);
					}
					text(Map.blocks.get(type), offset+App.MAPTILE_SIZE.x, j+App.MAPTILE_SIZE.y);
					triangle(
						offset-(App.MAPTILE_SIZE.x/2), j,
						offset-(App.MAPTILE_SIZE.x/2)+App.MAPTILE_SIZE.x, j,
						offset-(App.MAPTILE_SIZE.x/2), j+App.MAPTILE_SIZE.y
					);
					break;
				case "splitter":
					if (Map.blocks.get(type) > 0) {
						fill(255); stroke(255); strokeWeight(3);
					} else {
						fill(255, 50); stroke(255, 50); strokeWeight(3);
					}

					text(Map.blocks.get(type), offset+App.MAPTILE_SIZE.x, j+App.MAPTILE_SIZE.y);
					line(offset-(App.MAPTILE_SIZE.x/2), j, offset-(App.MAPTILE_SIZE.x/2)+App.MAPTILE_SIZE.x/3, j);
					line(offset-(App.MAPTILE_SIZE.x/2), j, offset-(App.MAPTILE_SIZE.x/2), j+App.MAPTILE_SIZE.y/3);

					line(offset-(App.MAPTILE_SIZE.x/2)+App.MAPTILE_SIZE.x, j+App.MAPTILE_SIZE.y, offset-(App.MAPTILE_SIZE.x/2)+App.MAPTILE_SIZE.x-App.MAPTILE_SIZE.x/3, j+App.MAPTILE_SIZE.y);
					line(offset-(App.MAPTILE_SIZE.x/2)+App.MAPTILE_SIZE.x, j+App.MAPTILE_SIZE.y, offset-(App.MAPTILE_SIZE.x/2)+App.MAPTILE_SIZE.x, j+App.MAPTILE_SIZE.y-App.MAPTILE_SIZE.y/3);

					line(offset-(App.MAPTILE_SIZE.x/2), j, offset-(App.MAPTILE_SIZE.x/2)+App.MAPTILE_SIZE.x, j+App.MAPTILE_SIZE.y);
					break;
				case "beam":
					if (Map.blocks.get(type) > 0) {
						fill(255, 25, 25); stroke(255); strokeWeight(1);
					} else {
						fill(255, 25, 25, 50); stroke(255, 50); strokeWeight(1);
					}
					text(Map.blocks.get(type), offset+App.MAPTILE_SIZE.x, j+App.MAPTILE_SIZE.y);
					rect(offset-(App.MAPTILE_SIZE.x/2), j, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
					break;
				case "sensor":
					if (Map.blocks.get(type) > 0) {
						fill(25, 25, 255); stroke(255); strokeWeight(1);
					} else {
						fill(25, 25, 255, 50); stroke(255, 50); strokeWeight(1);
					}
					text(Map.blocks.get(type), offset+App.MAPTILE_SIZE.x, j+App.MAPTILE_SIZE.y);
					rect(offset-(App.MAPTILE_SIZE.x/2), j, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
					break;
				case "and":
					if (Map.blocks.get(type) > 0) {
						fill(200, 200, 25); stroke(255); strokeWeight(1);
					} else {
						fill(200, 200, 25, 50); stroke(255, 50); strokeWeight(1);
					}
					text(Map.blocks.get(type), offset+App.MAPTILE_SIZE.x, j+App.MAPTILE_SIZE.y);
					rect(offset-(App.MAPTILE_SIZE.x/2), j, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
					if (Map.blocks.get(type) > 0) {
						fill(0); stroke(255); strokeWeight(1);
					} else {
						fill(0, 50); stroke(255, 50); strokeWeight(1);
					}
					rect(offset-(App.MAPTILE_SIZE.x/2)+App.MAPTILE_SIZE.x/4, j, App.MAPTILE_SIZE.x/2, App.MAPTILE_SIZE.y/8);
					break;
				case "or":
					if (Map.blocks.get(type) > 0) {
						fill(200, 25, 200); stroke(255); strokeWeight(1);
					} else {
						fill(200, 25, 200, 50); stroke(255, 50); strokeWeight(1);
					}
					text(Map.blocks.get(type), offset+App.MAPTILE_SIZE.x, j+App.MAPTILE_SIZE.y);
					rect(offset-(App.MAPTILE_SIZE.x/2), j, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
					if (Map.blocks.get(type) > 0) {
						fill(0); stroke(255); strokeWeight(1);
					} else {
						fill(0, 50); stroke(255, 50); strokeWeight(1);
					}
					rect(offset-(App.MAPTILE_SIZE.x/2)+App.MAPTILE_SIZE.x/4, j, App.MAPTILE_SIZE.x/2, App.MAPTILE_SIZE.y/8);
					break;
				case "xor":
					if (Map.blocks.get(type) > 0) {
						fill(25, 200, 200); stroke(255); strokeWeight(1);
					} else {
						fill(25, 200, 200, 50); stroke(255, 50); strokeWeight(1);
					}
					text(Map.blocks.get(type), offset+App.MAPTILE_SIZE.x, j+App.MAPTILE_SIZE.y);
					rect(offset-(App.MAPTILE_SIZE.x/2), j, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
					if (Map.blocks.get(type) > 0) {
						fill(0); stroke(255); strokeWeight(1);
					} else {
						fill(0, 50); stroke(255, 50); strokeWeight(1);
					}
					rect(offset-(App.MAPTILE_SIZE.x/2)+App.MAPTILE_SIZE.x/4, j, App.MAPTILE_SIZE.x/2, App.MAPTILE_SIZE.y/8);
					break;
			}
			j += App.TILETRAY_BLOCK_DISTANCE;
		}
	}

} Map Map;

class MapTile
{
	
	Vector pos;
	String type;

	Boolean preset = false;

	// Beam
	ArrayList<Vector> beam_body;
	Vector beam_dir;

	// Splitter && Reflector
	Integer rotation = 0;

	// Sensor
	Boolean hit = false;
	Boolean dstate = false;

	// Logic Blocks
	Integer laserCount = 0;
	Boolean notState = true;

	MapTile(Vector pos, String type) {
		this.pos  = pos;
		this.type = type;

		if (this.type == "beam") { this.beam_body = new ArrayList<Vector>(); this.beam_dir = new Vector(1, 0); }
	}
	MapTile(Vector pos, String type, Integer rot) {
		this.rotation = rot;
		this.pos  = pos;
		this.type = type;

		if (this.type == "beam") { this.beam_body = new ArrayList<Vector>(); this.beam_dir = new Vector(1, 0); }
	}
	MapTile(Vector pos, String type, Boolean dstate) {
		this.pos  = pos;
		this.type = type;

		if (this.type == "sensor") { this.dstate = dstate; }
	}
	MapTile(Vector pos, String type, Vector dir) {
		this.pos  = pos;
		this.type = type;

		if (this.type == "beam") { this.beam_body = new ArrayList<Vector>(); this.beam_dir = new Vector(dir); }
	}

	void render() {
		switch(this.type) {
			case "null":
				break;
			case "beam":
				break;
			case "block":
				fill(255); stroke(255); strokeWeight(1);
				rect(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
				break;
			case "sensor":
				if (this.hit == !this.dstate) { fill(0, 255, 0); } else { fill(0, 0, 255); }stroke(255); strokeWeight(1);
				rect(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
				break;
			case "splitter":
				switch(this.rotation) {
					case 0:
						fill(255); stroke(255); strokeWeight(3);
						line(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y, this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/3, this.pos.y*App.MAPTILE_SIZE.y);
						line(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y, this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/3);

						line(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y, this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x-App.MAPTILE_SIZE.x/3, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y);
						line(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y, this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y-App.MAPTILE_SIZE.y/3);

						line(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y, this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y);
						break;
					case 1:
						fill(255); stroke(255); strokeWeight(3);
						line(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y, this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x-App.MAPTILE_SIZE.x/3, this.pos.y*App.MAPTILE_SIZE.y);
						line(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y, this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/3);

						line(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y, this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/3, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y);
						line(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y, this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y-App.MAPTILE_SIZE.y/3);

						line(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y, this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y);
						break;
				}
				break;
			case "reflector":
				fill(255); stroke(255); strokeWeight(1);
				switch(this.rotation) {
					case 0:
						triangle(
							this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y,
							this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y,
							this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y
						);
						break;
					case 1:
						triangle(
							this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y,
							this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y,
							this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y
						);
						break;
					case 2:
						triangle(
							this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y,
							this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y,
							this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y
						);
						break;
					case 3:
						triangle(
							this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y,
							this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y,
							this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y
						);
						break;
				}
				break;
			case "and":
				fill(200, 200, 25); stroke(255); strokeWeight(1);
				rect(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
				fill(0); stroke(0); strokeWeight(1); textAlign(CENTER); textSize(12);
				text("AND", this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/2, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/2+5);
				fill(0); stroke(0); strokeWeight(1);
				switch (this.rotation) {
					case 0:
						rect(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/4, this.pos.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x/2, App.MAPTILE_SIZE.y/8);
						break;
					case 1:
						rect(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x-App.MAPTILE_SIZE.x/8, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/4, App.MAPTILE_SIZE.x/8, App.MAPTILE_SIZE.y/2);
						break;
					case 2:
						rect(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/4, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y-App.MAPTILE_SIZE.y/8, App.MAPTILE_SIZE.x/2, App.MAPTILE_SIZE.y/8);
						break;
					case 3:
						rect(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/4, App.MAPTILE_SIZE.x/8, App.MAPTILE_SIZE.y/2);
						break;
				}
				break;
			case "or":
				fill(200, 25, 200); stroke(255); strokeWeight(1);
				rect(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
				fill(0); stroke(0); strokeWeight(1); textAlign(CENTER); textSize(12);
				text("OR", this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/2, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/2+5);
				fill(0); stroke(0); strokeWeight(1);
				switch (this.rotation) {
					case 0:
						rect(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/4, this.pos.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x/2, App.MAPTILE_SIZE.y/8);
						break;
					case 1:
						rect(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x-App.MAPTILE_SIZE.x/8, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/4, App.MAPTILE_SIZE.x/8, App.MAPTILE_SIZE.y/2);
						break;
					case 2:
						rect(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/4, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y-App.MAPTILE_SIZE.y/8, App.MAPTILE_SIZE.x/2, App.MAPTILE_SIZE.y/8);
						break;
					case 3:
						rect(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/4, App.MAPTILE_SIZE.x/8, App.MAPTILE_SIZE.y/2);
						break;
				}
				break;
			case "xor":
				fill(25, 200, 200); stroke(255); strokeWeight(1);
				rect(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
				fill(0); stroke(0); strokeWeight(1); textAlign(CENTER); textSize(12);
				text("xor", this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/2, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/2+5);
				fill(0); stroke(0); strokeWeight(1);
				switch (this.rotation) {
					case 0:
						rect(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/4, this.pos.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x/2, App.MAPTILE_SIZE.y/8);
						break;
					case 1:
						rect(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x-App.MAPTILE_SIZE.x/8, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/4, App.MAPTILE_SIZE.x/8, App.MAPTILE_SIZE.y/2);
						break;
					case 2:
						rect(this.pos.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x/4, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y-App.MAPTILE_SIZE.y/8, App.MAPTILE_SIZE.x/2, App.MAPTILE_SIZE.y/8);
						break;
					case 3:
						rect(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y/4, App.MAPTILE_SIZE.x/8, App.MAPTILE_SIZE.y/2);
						break;
				}
				break;
		}
	}

	void render_beam() {
		if (this.type == "beam" || this.type == "xor") {
			if (this.type == "beam") {
				fill(255, 25, 25); stroke(255); strokeWeight(1);
				rect(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
			}
			fill(255, 25, 25, 200); stroke(255); strokeWeight(1);
			if (this.beam_body != null) { for (Vector b : this.beam_body) { switch(Map.tiles[b.x][b.y].type) { // Special Block Interactions E.G. Splitters, Reflectors
				case "null":
					rect(b.x*App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
					break;
				case "splitter":
					rect(b.x*App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
					break;
				case "reflector":
					switch(Map.tiles[b.x][b.y].rotation) {
						case 0:
							triangle(
								b.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y,
								b.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y,
								b.x*App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y
							);
							break;
						case 1:
							triangle(
								b.x*App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y,
								b.x*App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y,
								b.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y
							);
							break;
						case 2:
							triangle(
								b.x*App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y,
								b.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y,
								b.x*App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y
							);
							break;
						case 3:
							triangle(
								b.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y,
								b.x*App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y,
								b.x*App.MAPTILE_SIZE.x+App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y+App.MAPTILE_SIZE.y
							);
							break;
					}
					break;
			} } }
		}
	}

	void fire() { this.fire(false, this.pos, this.beam_dir); }
	void fire(Boolean secondFire, Vector newpos, Vector newdir) {
		if (secondFire == false) { this.beam_body = new ArrayList<Vector>(); }
		if (this.type == "beam" || this.type == "xor") { // Calculate Beam Postion
			//Set Vars For Beam Body
			Vector body_pos = new Vector(newpos);
			Vector body_dir = new Vector(newdir);
      		Integer tempTimes = 0;

			while(true && tempTimes < App.BEAM_LENGTH_MAX) {
				body_pos.add(body_dir); tempTimes++;
				// Handle Out Of Bounds
				if (body_pos.x < 0 || body_pos.x >= Map.tiles.length)    { /*println("Beam Broken.");*/ break; }
				if (body_pos.y < 0 || body_pos.y >= Map.tiles[0].length) { /*println("Beam Broken.");*/ break; }
				// Handle Filled Tiles
				Boolean breakBeam = false;
				if (Map.tiles[body_pos.x][body_pos.y].type != "null") { switch(Map.tiles[body_pos.x][body_pos.y].type) {
					case "block": // Break Beam
						breakBeam = true;
						break;
					case "and":
						Map.tiles[body_pos.x][body_pos.y].laserCount += 1;
						if (Map.tiles[body_pos.x][body_pos.y].laserCount >= 2) {
							try {
								switch(Map.tiles[body_pos.x][body_pos.y].rotation) {
									case 0:
										if (body_pos.y - 1 < 0) { breakBeam = true; throw new ArrayIndexOutOfBoundsException("Beam Out Of Bounds"); }
										body_dir = new Vector(0, -1);
										break;
									case 1:
										if (body_pos.x + 1 >= App.MAP_SIZE.x) { breakBeam = true; throw new ArrayIndexOutOfBoundsException("Beam Out Of Bounds"); }
										body_dir = new Vector(1, 0);
										break;
									case 2:
										if (body_pos.y + 1 >= App.MAP_SIZE.y) { breakBeam = true; throw new ArrayIndexOutOfBoundsException("Beam Out Of Bounds"); }
										body_dir = new Vector(0, 1);
										break;
									case 3:
										if (body_pos.x - 1 < 0) { breakBeam = true; throw new ArrayIndexOutOfBoundsException("Beam Out Of Bounds"); }
										body_dir = new Vector(-1, 0);
										break;
								}
							} catch (ArrayIndexOutOfBoundsException e) { breakBeam = true; }
						} else {
							breakBeam = true;
						}
						break;
					case "or":
						Map.tiles[body_pos.x][body_pos.y].laserCount += 1;
						if (Map.tiles[body_pos.x][body_pos.y].laserCount >= 1) {
							try {
								switch(Map.tiles[body_pos.x][body_pos.y].rotation) {
									case 0:
										if (body_pos.y - 1 < 0) { breakBeam = true; throw new ArrayIndexOutOfBoundsException("Beam Out Of Bounds"); }
										body_dir = new Vector(0, -1);
										break;
									case 1:
										if (body_pos.x + 1 >= App.MAP_SIZE.x) { breakBeam = true; throw new ArrayIndexOutOfBoundsException("Beam Out Of Bounds"); }
										body_dir = new Vector(1, 0);
										break;
									case 2:
										if (body_pos.y + 1 >= App.MAP_SIZE.y) { breakBeam = true; throw new ArrayIndexOutOfBoundsException("Beam Out Of Bounds"); }
										body_dir = new Vector(0, 1);
										break;
									case 3:
										if (body_pos.x - 1 < 0) { breakBeam = true; throw new ArrayIndexOutOfBoundsException("Beam Out Of Bounds"); }
										body_dir = new Vector(-1, 0);
										break;
								}
							} catch (ArrayIndexOutOfBoundsException e) { breakBeam = true; }
						} else {
							breakBeam = true;
						}
						break;
					case "xor":
						Map.tiles[body_pos.x][body_pos.y].laserCount += 1;
						breakBeam = true;
						break;
					case "beam": // Do Nothing
						break;
					case "splitter":
						switch(Map.tiles[body_pos.x][body_pos.y].rotation) {
							case 0:
								try {
									this.fire(true, new Vector(body_pos.x, body_pos.y), new Vector(body_dir.y, body_dir.x));
								} catch(StackOverflowError e) {
									Map.tiles[body_pos.x][body_pos.y] = new MapTile(new Vector(body_pos), "null");
									breakBeam = true;
									Map.calculate_beams();
								}
								break;
							case 1:
								try {
									this.fire(true, new Vector(body_pos.x, body_pos.y), new Vector(-1*body_dir.y, -1*body_dir.x));
								} catch(StackOverflowError e) {
									Map.tiles[body_pos.x][body_pos.y] = new MapTile(new Vector(body_pos), "null");
									breakBeam = true;
									Map.calculate_beams();
								}
								break;
						}
						break;
					case "reflector":
						switch(Map.tiles[body_pos.x][body_pos.y].rotation) {
							case 0:
								if ((body_dir.x == -1 && body_dir.y == 0) || (body_dir.x == 0 && body_dir.y == -1))  {
									body_dir = new Vector(-1*body_dir.y, -1*body_dir.x);
								} else { breakBeam = true; }
								break;
							case 1:
								if ((body_dir.x == 1 && body_dir.y == 0) || (body_dir.x == 0 && body_dir.y == -1))  {
									body_dir = new Vector(body_dir.y, body_dir.x);
								} else { breakBeam = true; }
								break;
							case 2:
								if ((body_dir.x == 1 && body_dir.y == 0) || (body_dir.x == 0 && body_dir.y == 1))  {
									body_dir = new Vector(-1*body_dir.y, -1*body_dir.x);
								} else { breakBeam = true; }
								break;
							case 3:
								if ((body_dir.x == -1 && body_dir.y == 0) || (body_dir.x == 0 && body_dir.y == 1))  {
									body_dir = new Vector(body_dir.y, body_dir.x);
								} else { breakBeam = true; }
								break;
						}
						break;
					case "sensor":
						Map.tiles[body_pos.x][body_pos.y].hit = true;
						break;
				} }
				if (breakBeam) { break; }
				else { switch(Map.tiles[body_pos.x][body_pos.y].type) { // Special Block Interactions E.G. Splitters, Reflectors
					default:
						this.beam_body.add(new Vector(body_pos.x, body_pos.y));
						break;
				} }
			}
		} else {
			println("Type != beam!");
		}
	}
}

// Map Presets
class MapPreset {
	// Default Presets
	MapTile[] preset__basic_map = {
	}; IntDict preset__basic_map_blocks;

	MapPreset() { // Create Block Dicts
		preset__basic_map_blocks = new IntDict();
		preset__basic_map_blocks.set("block", 99); preset__basic_map_blocks.set("reflector", 99); preset__basic_map_blocks.set("splitter", 99); preset__basic_map_blocks.set("beam", 99); preset__basic_map_blocks.set("sensor", 99); preset__basic_map_blocks.set("and", 99); preset__basic_map_blocks.set("or", 99); preset__basic_map_blocks.set("xor", 99);
	}
}

// Base Levels
// Level 1 - Basic Reflection
MapTile[] base__level__1 = {new MapTile(new Vector(0,5), "reflector", 2),new MapTile(new Vector(0,6), "block"),new MapTile(new Vector(0,7), "block"),new MapTile(new Vector(0,8), "block"),new MapTile(new Vector(0,9), "reflector", 1),new MapTile(new Vector(1,5), "block"),new MapTile(new Vector(1,6), "beam", new Vector(1,0)),new MapTile(new Vector(1,7), "block"),new MapTile(new Vector(1,8), "block"),new MapTile(new Vector(1,9), "block"),new MapTile(new Vector(2,5), "block"),new MapTile(new Vector(2,9), "block"),new MapTile(new Vector(3,5), "block"),new MapTile(new Vector(3,9), "block"),new MapTile(new Vector(4,5), "block"),new MapTile(new Vector(4,9), "block"),new MapTile(new Vector(5,5), "block"),new MapTile(new Vector(5,9), "block"),new MapTile(new Vector(6,5), "block"),new MapTile(new Vector(6,9), "block"),new MapTile(new Vector(7,5), "block"),new MapTile(new Vector(7,9), "block"),new MapTile(new Vector(8,5), "block"),new MapTile(new Vector(8,9), "block"),new MapTile(new Vector(9,5), "block"),new MapTile(new Vector(9,9), "block"),new MapTile(new Vector(10,5), "block"),new MapTile(new Vector(10,9), "block"),new MapTile(new Vector(11,5), "block"),new MapTile(new Vector(11,9), "block"),new MapTile(new Vector(12,5), "block"),new MapTile(new Vector(12,9), "block"),new MapTile(new Vector(13,5), "block"),new MapTile(new Vector(13,6), "block"),new MapTile(new Vector(13,7), "block"),new MapTile(new Vector(13,8), "sensor", false),new MapTile(new Vector(13,9), "block"),new MapTile(new Vector(14,5), "reflector", 3),new MapTile(new Vector(14,6), "block"),new MapTile(new Vector(14,7), "block"),new MapTile(new Vector(14,8), "block"),new MapTile(new Vector(14,9), "reflector", 0)};
String[]  base__level__1_blocks_keys   = {"block","reflector","splitter", "beam", "sensor", "and", "or", "xor"};
int[]     base__level__1_blocks_values = {0      , 2         , 0        , 0    , 0        , 0    , 0   , 0    };
IntDict   base__level__1_blocks = new IntDict(base__level__1_blocks_keys, base__level__1_blocks_values);

// Level 2 - Seeing Double
MapTile[] base__level__2 = {new MapTile(new Vector(0,0), "block"),new MapTile(new Vector(0,1), "block"),new MapTile(new Vector(0,2), "block"),new MapTile(new Vector(0,3), "block"),new MapTile(new Vector(0,4), "block"),new MapTile(new Vector(0,5), "block"),new MapTile(new Vector(0,6), "block"),new MapTile(new Vector(1,0), "block"),new MapTile(new Vector(1,1), "reflector", 0),new MapTile(new Vector(1,2), "sensor", false),new MapTile(new Vector(1,3), "block"),new MapTile(new Vector(1,4), "sensor", false),new MapTile(new Vector(1,5), "reflector", 3),new MapTile(new Vector(1,6), "block"),new MapTile(new Vector(1,13), "beam", new Vector(1,0)),new MapTile(new Vector(2,0), "block"),new MapTile(new Vector(2,3), "block"),new MapTile(new Vector(2,6), "block"),new MapTile(new Vector(3,0), "block"),new MapTile(new Vector(3,3), "block"),new MapTile(new Vector(3,6), "block"),new MapTile(new Vector(4,3), "block"),new MapTile(new Vector(12,0), "reflector", 1),new MapTile(new Vector(12,14), "reflector", 2),new MapTile(new Vector(13,0), "block"),new MapTile(new Vector(13,1), "reflector", 1),new MapTile(new Vector(13,13), "reflector", 2),new MapTile(new Vector(13,14), "block"),new MapTile(new Vector(14,0), "block"),new MapTile(new Vector(14,1), "block"),new MapTile(new Vector(14,2), "reflector", 1),new MapTile(new Vector(14,12), "reflector", 2),new MapTile(new Vector(14,13), "block"),new MapTile(new Vector(14,14), "block")};
String[]  base__level__2_blocks_keys   = {"block","reflector","splitter", "beam", "sensor", "and", "or", "xor"};
int[]     base__level__2_blocks_values = {0      , 0         , 1        , 0    , 0        , 0    , 0   , 0    };
IntDict   base__level__2_blocks = new IntDict(base__level__2_blocks_keys, base__level__2_blocks_values);

// Level 3 - Not Sensor?
MapTile[] base__level__3 = {new MapTile(new Vector(2,9), "beam", new Vector(1,0)),new MapTile(new Vector(5,5), "reflector", 2),new MapTile(new Vector(5,6), "reflector", 1),new MapTile(new Vector(6,5), "reflector", 3),new MapTile(new Vector(6,6), "block"),new MapTile(new Vector(6,7), "reflector", 1),new MapTile(new Vector(7,6), "reflector", 3),new MapTile(new Vector(7,7), "reflector", 0),new MapTile(new Vector(7,9), "splitter", 1),new MapTile(new Vector(12,7), "sensor", false),new MapTile(new Vector(12,9), "sensor", true),new MapTile(new Vector(13,5), "block"),new MapTile(new Vector(13,6), "reflector", 1),new MapTile(new Vector(13,10), "reflector", 2),new MapTile(new Vector(13,11), "block"),new MapTile(new Vector(14,5), "block"),new MapTile(new Vector(14,6), "block"),new MapTile(new Vector(14,7), "block"),new MapTile(new Vector(14,8), "block"),new MapTile(new Vector(14,9), "block"),new MapTile(new Vector(14,10), "block"),new MapTile(new Vector(14,11), "block")};
String[]  base__level__3_blocks_keys   = {"block","reflector","splitter", "beam", "sensor", "and", "or", "xor"};
int[]     base__level__3_blocks_values = {1      , 0         , 0        , 0    , 0        , 0    , 0   , 0    };
IntDict   base__level__3_blocks = new IntDict(base__level__3_blocks_keys, base__level__3_blocks_values);

// Level 4 - Broken Lasers
MapTile[] base__level__4 = {new MapTile(new Vector(0,0), "reflector", 2),new MapTile(new Vector(0,1), "block"),new MapTile(new Vector(0,2), "block"),new MapTile(new Vector(0,3), "block"),new MapTile(new Vector(0,4), "block"),new MapTile(new Vector(0,5), "block"),new MapTile(new Vector(0,6), "reflector", 1),new MapTile(new Vector(1,0), "block"),new MapTile(new Vector(1,1), "beam", new Vector(0,1)),new MapTile(new Vector(1,2), "block"),new MapTile(new Vector(1,3), "beam", new Vector(1,0)),new MapTile(new Vector(1,4), "block"),new MapTile(new Vector(1,5), "beam", new Vector(0,1)),new MapTile(new Vector(1,6), "block"),new MapTile(new Vector(2,0), "reflector", 3),new MapTile(new Vector(2,2), "reflector", 3),new MapTile(new Vector(2,4), "reflector", 0),new MapTile(new Vector(2,6), "reflector", 0),new MapTile(new Vector(8,0), "reflector", 1),new MapTile(new Vector(8,2), "reflector", 1),new MapTile(new Vector(8,4), "reflector", 1),new MapTile(new Vector(8,12), "reflector", 2),new MapTile(new Vector(8,13), "block"),new MapTile(new Vector(8,14), "reflector", 1),new MapTile(new Vector(9,0), "block"),new MapTile(new Vector(9,2), "block"),new MapTile(new Vector(9,4), "block"),new MapTile(new Vector(9,5), "reflector", 1),new MapTile(new Vector(9,13), "sensor", false),new MapTile(new Vector(9,14), "block"),new MapTile(new Vector(10,0), "block"),new MapTile(new Vector(10,2), "block"),new MapTile(new Vector(10,4), "reflector", 3),new MapTile(new Vector(10,5), "block"),new MapTile(new Vector(10,6), "reflector", 1),new MapTile(new Vector(10,12), "reflector", 2),new MapTile(new Vector(10,13), "block"),new MapTile(new Vector(10,14), "block"),new MapTile(new Vector(11,0), "block"),new MapTile(new Vector(11,2), "block"),new MapTile(new Vector(11,3), "reflector", 1),new MapTile(new Vector(11,13), "sensor", false),new MapTile(new Vector(11,14), "block"),new MapTile(new Vector(12,0), "block"),new MapTile(new Vector(12,2), "reflector", 3),new MapTile(new Vector(12,3), "block"),new MapTile(new Vector(12,4), "block"),new MapTile(new Vector(12,5), "block"),new MapTile(new Vector(12,6), "reflector", 1),new MapTile(new Vector(12,12), "reflector", 3),new MapTile(new Vector(12,13), "block"),new MapTile(new Vector(12,14), "block"),new MapTile(new Vector(13,0), "block"),new MapTile(new Vector(13,1), "reflector", 1),new MapTile(new Vector(13,13), "sensor", false),new MapTile(new Vector(13,14), "block"),new MapTile(new Vector(14,0), "block"),new MapTile(new Vector(14,1), "block"),new MapTile(new Vector(14,2), "block"),new MapTile(new Vector(14,3), "block"),new MapTile(new Vector(14,4), "block"),new MapTile(new Vector(14,5), "block"),new MapTile(new Vector(14,6), "reflector", 1),new MapTile(new Vector(14,12), "reflector", 3),new MapTile(new Vector(14,13), "block"),new MapTile(new Vector(14,14), "reflector", 0)};
String[]  base__level__4_blocks_keys   = {"block","reflector","splitter", "beam", "sensor", "and", "or", "xor"};
int[]     base__level__4_blocks_values = {0      , 2         , 2        , 0    , 0        , 0    , 0   , 0    };
IntDict   base__level__4_blocks = new IntDict(base__level__4_blocks_keys, base__level__4_blocks_values);






// Custom Presets - Paset Preset Here and in Map.load_preset(); enter the name of your preset E.G. Map.load_preset(custom_map__test);
MapTile[] custom_map__test = {new MapTile(new Vector(0,8), "block"),new MapTile(new Vector(0,9), "block"),new MapTile(new Vector(0,10), "block"),new MapTile(new Vector(1,1), "beam", new Vector(1,0)),new MapTile(new Vector(1,1), "beam"),new MapTile(new Vector(1,8), "block"),new MapTile(new Vector(1,9), "block"),new MapTile(new Vector(1,10), "block"),new MapTile(new Vector(2,8), "block"),new MapTile(new Vector(2,9), "block"),new MapTile(new Vector(2,10), "block"),new MapTile(new Vector(3,3), "reflector", 2),new MapTile(new Vector(3,4), "reflector", 1),new MapTile(new Vector(3,8), "reflector", 3),new MapTile(new Vector(3,9), "sensor"),new MapTile(new Vector(3,10), "reflector", 0),new MapTile(new Vector(4,3), "reflector", 3),new MapTile(new Vector(4,4), "reflector", 0),new MapTile(new Vector(6,13), "reflector", 2),new MapTile(new Vector(6,14), "block"),new MapTile(new Vector(7,13), "reflector", 3),new MapTile(new Vector(7,14), "block"),new MapTile(new Vector(8,1), "splitter", 0),new MapTile(new Vector(12,0), "reflector", 1),new MapTile(new Vector(13,0), "block"),new MapTile(new Vector(13,1), "reflector", 1),new MapTile(new Vector(13,9), "reflector", 2),new MapTile(new Vector(13,10), "reflector", 1),new MapTile(new Vector(13,13), "sensor"),new MapTile(new Vector(14,0), "block"),new MapTile(new Vector(14,1), "block"),new MapTile(new Vector(14,2), "reflector", 1),new MapTile(new Vector(14,9), "block"),new MapTile(new Vector(14,10), "block")};
String[]  custom_map__test_blocks_keys   = {"block","reflector","splitter", "beam", "sensor", "and", "or", "xor"};
int[]     custom_map__test_blocks_values = {0      , 2         , 1        , 0     , 0       , 0    , 0   , 0    };
IntDict   custom_map__test_blocks = new IntDict(custom_map__test_blocks_keys, custom_map__test_blocks_values);

MapTile[] threebitcalc = {new MapTile(new Vector(1,0), "beam", new Vector(0,1)),new MapTile(new Vector(1,17), "reflector", 3),new MapTile(new Vector(2,0), "beam", new Vector(0,1)),new MapTile(new Vector(2,9), "reflector", 3),new MapTile(new Vector(3,0), "beam", new Vector(0,1)),new MapTile(new Vector(3,3), "reflector", 3),new MapTile(new Vector(6,0), "beam", new Vector(0,1)),new MapTile(new Vector(6,16), "reflector", 3),new MapTile(new Vector(7,0), "beam", new Vector(0,1)),new MapTile(new Vector(7,8), "reflector", 3),new MapTile(new Vector(7,12), "reflector", 0),new MapTile(new Vector(7,18), "reflector", 3),new MapTile(new Vector(8,0), "beam", new Vector(0,1)),new MapTile(new Vector(8,2), "reflector", 3),new MapTile(new Vector(8,4), "reflector", 0),new MapTile(new Vector(8,10), "reflector", 3),new MapTile(new Vector(8,13), "block"),new MapTile(new Vector(8,14), "reflector", 0),new MapTile(new Vector(8,16), "splitter", 1),new MapTile(new Vector(9,5), "block"),new MapTile(new Vector(9,6), "reflector", 0),new MapTile(new Vector(9,8), "splitter", 1),new MapTile(new Vector(9,14), "xor", 1),new MapTile(new Vector(9,17), "splitter", 1),new MapTile(new Vector(10,0), "reflector", 0),new MapTile(new Vector(10,3), "splitter", 1),new MapTile(new Vector(10,5), "block"),new MapTile(new Vector(10,6), "xor", 1),new MapTile(new Vector(10,9), "splitter", 1),new MapTile(new Vector(10,13), "block"),new MapTile(new Vector(10,14), "splitter", 0),new MapTile(new Vector(10,19), "reflector", 3),new MapTile(new Vector(11,1), "reflector", 0),new MapTile(new Vector(11,2), "splitter", 1),new MapTile(new Vector(11,5), "block"),new MapTile(new Vector(11,6), "splitter", 0),new MapTile(new Vector(11,11), "reflector", 3),new MapTile(new Vector(11,13), "block"),new MapTile(new Vector(11,14), "xor", 1),new MapTile(new Vector(11,18), "splitter", 1),new MapTile(new Vector(12,0), "reflector", 1),new MapTile(new Vector(12,1), "xor", 1),new MapTile(new Vector(12,2), "reflector", 1),new MapTile(new Vector(12,3), "and", 1),new MapTile(new Vector(12,5), "block"),new MapTile(new Vector(12,6), "xor", 1),new MapTile(new Vector(12,10), "splitter", 1),new MapTile(new Vector(12,13), "block"),new MapTile(new Vector(12,16), "and", 1),new MapTile(new Vector(12,17), "reflector", 2),new MapTile(new Vector(12,18), "and", 1),new MapTile(new Vector(12,19), "reflector", 2),new MapTile(new Vector(13,3), "reflector", 1),new MapTile(new Vector(13,4), "reflector", 2),new MapTile(new Vector(13,5), "block"),new MapTile(new Vector(13,8), "and", 1),new MapTile(new Vector(13,9), "reflector", 2),new MapTile(new Vector(13,10), "and", 1),new MapTile(new Vector(13,11), "reflector", 2),new MapTile(new Vector(13,13), "block"),new MapTile(new Vector(13,16), "reflector", 1),new MapTile(new Vector(13,17), "or", 1),new MapTile(new Vector(13,18), "reflector", 2),new MapTile(new Vector(14,8), "reflector", 1),new MapTile(new Vector(14,9), "or", 1),new MapTile(new Vector(14,10), "reflector", 2),new MapTile(new Vector(16,9), "reflector", 1),new MapTile(new Vector(16,12), "reflector", 2),new MapTile(new Vector(19,17), "reflector", 1),new MapTile(new Vector(19,21), "sensor", false),new MapTile(new Vector(19,22), "block"),new MapTile(new Vector(20,14), "reflector", 1),new MapTile(new Vector(20,21), "sensor", false),new MapTile(new Vector(20,22), "block"),new MapTile(new Vector(21,6), "reflector", 1),new MapTile(new Vector(21,21), "sensor", false),new MapTile(new Vector(21,22), "block"),new MapTile(new Vector(22,1), "reflector", 1),new MapTile(new Vector(22,21), "sensor", false),new MapTile(new Vector(22,22), "block")};
String[]  threebitcalc_blocks_keys   = {"block","reflector","splitter", "beam", "sensor", "and", "or", "xor"};
int[]     threebitcalc_blocks_values = {99      , 99         , 99        , 99    , 99   , 99   , 99  , 99   };
IntDict   threebitcalc_blocks = new IntDict(threebitcalc_blocks_keys, threebitcalc_blocks_values);
//// Example ^^^ Example //// Copy Paste and edit values ////
MapTile[] custom_spiral = {new MapTile(new Vector(1,1), "beam", new Vector(1,0)),new MapTile(new Vector(1,1), "beam"),new MapTile(new Vector(4,6), "block"),new MapTile(new Vector(4,7), "block"),new MapTile(new Vector(4,8), "block"),new MapTile(new Vector(4,9), "block"),new MapTile(new Vector(4,10), "block"),new MapTile(new Vector(4,11), "block"),new MapTile(new Vector(4,12), "block"),new MapTile(new Vector(4,13), "block"),new MapTile(new Vector(4,14), "block"),new MapTile(new Vector(5,6), "block"),new MapTile(new Vector(5,7), "reflector", 0),new MapTile(new Vector(5,14), "reflector", 3),new MapTile(new Vector(6,6), "block"),new MapTile(new Vector(6,8), "reflector", 0),new MapTile(new Vector(6,13), "reflector", 3),new MapTile(new Vector(7,6), "block"),new MapTile(new Vector(7,9), "reflector", 0),new MapTile(new Vector(7,12), "reflector", 3),new MapTile(new Vector(8,6), "block"),new MapTile(new Vector(8,10), "reflector", 0),new MapTile(new Vector(8,11), "reflector", 3),new MapTile(new Vector(9,0), "block"),new MapTile(new Vector(9,1), "reflector", 1),new MapTile(new Vector(10,0), "block"),new MapTile(new Vector(10,1), "block"),new MapTile(new Vector(10,6), "block"),new MapTile(new Vector(10,10), "reflector", 1),new MapTile(new Vector(10,12), "reflector", 2),new MapTile(new Vector(11,6), "block"),new MapTile(new Vector(11,9), "reflector", 1),new MapTile(new Vector(11,13), "reflector", 2),new MapTile(new Vector(12,6), "block"),new MapTile(new Vector(12,8), "reflector", 1),new MapTile(new Vector(12,14), "reflector", 2),new MapTile(new Vector(13,6), "block"),new MapTile(new Vector(13,7), "reflector", 1),new MapTile(new Vector(13,13), "sensor"),new MapTile(new Vector(13,14), "block"),new MapTile(new Vector(14,6), "block"),new MapTile(new Vector(14,7), "block"),new MapTile(new Vector(14,8), "block"),new MapTile(new Vector(14,9), "block"),new MapTile(new Vector(14,10), "block"),new MapTile(new Vector(14,11), "block"),new MapTile(new Vector(14,12), "block"),new MapTile(new Vector(14,13), "block"),new MapTile(new Vector(14,14), "block")};
String[]  custom_spiral_blocks_keys   = {"block","reflector","splitter", "beam", "sensor", "and", "or", "xor"};
int[]     custom_spiral_blocks_values = {0      , 1         , 0        , 0     , 0       , 0    , 0   , 0    };
IntDict   custom_spiral_blocks = new IntDict(custom_spiral_blocks_keys, custom_spiral_blocks_values);
