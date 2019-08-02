class Renderer {
	/* By using this class, i can specify if i want to rerender the screen to make smooth animations. */
	Renderer() { println("Renderer Initialized Successfully."); } // Constructor
	void render_all() { // Render Whole Frame
		background(0); // Refresh Screen
		Map.render_background(); // Draw Grid
		// Draw Beam
		Map.render_tiles(); // Draw Tiles
		if (App.DRAGGING == true) { Map.render_dragtile(); }
	}
} Renderer Renderer;