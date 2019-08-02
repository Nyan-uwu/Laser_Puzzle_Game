void setup() {
	size(501, 501);
	// Init Application
	Vector window_size = new Vector(width-1, height-1);
	Vector map_size = new Vector(10, 10);
	Vector maptile_size = new Vector(floor(window_size.x/map_size.x), floor(window_size.y/map_size.y));
	App.init(window_size, map_size, maptile_size);
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

	Map(Vector map_size) {
		this.tiles = new MapTile[map_size.x][map_size.y]; // Create Tiles
		this.beams = new ArrayList<Vector>();

		this.load_preset("preset__basic_map"); // Load Preset
	}

	void load_preset(String preset) {
		if (preset != null) {
			MapPreset mp = new MapPreset();
			MapTile[] presetarr = null;
			// Load Preset
			switch(preset) {
				case "preset__basic_map":
					presetarr = mp.preset__basic_map;
					break;
			}

			for (Integer i = 0; i < this.tiles.length; i++) { // Populate Map With Tiles
				for (Integer j = 0; j < this.tiles[i].length; j++) {
					this.tiles[i][j] = new MapTile(new Vector(i, j), "null");
				}
			}

			if (presetarr != null) {
				// Import Preset
				for (MapTile mt : presetarr) {
					this.tiles[mt.pos.x][mt.pos.y] = mt;
					this.tiles[mt.pos.x][mt.pos.y].preset = true;
				}

				// Find Beams
				for (MapTile[] arr : this.tiles) {
					for (MapTile mt : arr) {
						if (mt.type == "beam") { this.beams.add(new Vector(mt.pos.x, mt.pos.y)); println("Beam Found @ " + mt.pos.x + ":" + mt.pos.y); }
					}
				}

				println("Preset \"" + preset + "\" Has Been Loaded");
				println("--------------------");
			} else {
				println("Preset Does Not Exist.");
			}
		}
	}

	void calculate_beams() {
		for (Vector b : Map.beams) { Map.tiles[b.x][b.y].fire(); }
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
				mt.render();
			}
		}
	}

	void render_dragtile() {
		// Get Mouse Position
		Integer[] arrpos = Mousef.posToArrPos(mouseX, mouseY);
		Vector mpos = new Vector(arrpos[0], arrpos[1]); // println("mpos.x : mpos.y: "+mpos.x+":"+mpos.y);

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
		}
	}

	void render_beam() {
		if (this.type == "beam") {
			fill(255, 25, 25); stroke(255); strokeWeight(1);
			rect(this.pos.x*App.MAPTILE_SIZE.x, this.pos.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
			fill(255, 25, 25, 200); stroke(255); strokeWeight(1);
			if (this.beam_body != null) { for (Vector b : this.beam_body) { switch(Map.tiles[b.x][b.y].type) { // Special Block Interactions E.G. Splitters, Reflectors
				case "null":
					rect(b.x*App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
					break;
				case "splitter":
					rect(b.x*App.MAPTILE_SIZE.x, b.y*App.MAPTILE_SIZE.y, App.MAPTILE_SIZE.x, App.MAPTILE_SIZE.y);
					break;
			} } }
		}
	}

	void fire() { this.fire(false, this.pos, this.beam_dir); }
	void fire(Boolean secondFire, Vector newpos, Vector newdir) {
		if (secondFire == false) { this.beam_body = new ArrayList<Vector>(); }
		if (this.type == "beam") { // Calculate Beam Postion
			//Set Vars For Beam Body
			Vector body_pos = new Vector(newpos);
			Vector body_dir = new Vector(newdir);

			while(true) {
				body_pos.add(body_dir);
				// Handle Out Of Bounds
				if (body_pos.x < 0 || body_pos.x >= Map.tiles.length)    { /*println("Beam Broken.");*/ break; }
				if (body_pos.y < 0 || body_pos.y >= Map.tiles[0].length) { /*println("Beam Broken.");*/ break; }
				// Handle Filled Tiles
				Boolean breakBeam = false;
				if (Map.tiles[body_pos.x][body_pos.y].type != "null") { switch(Map.tiles[body_pos.x][body_pos.y].type) {
					case "block": // Break Beam
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
								}
								break;
							case 1:
								try {
									this.fire(true, new Vector(body_pos.x, body_pos.y), new Vector(-1*body_dir.y, -1*body_dir.x));
								} catch(StackOverflowError e) {
									Map.tiles[body_pos.x][body_pos.y] = new MapTile(new Vector(body_pos), "null");
									breakBeam = true;
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
		new MapTile(new Vector(1, 1), "beam"), new MapTile(new Vector(8, 1), "block"), new MapTile(new Vector(5, 1), "reflector", 1)
	};

	// Custom Presets
}