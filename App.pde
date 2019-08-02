static class App {
	static Vector WINDOW_SIZE;

	static Vector MAP_SIZE;

	static Vector MAPTILE_SIZE;
	static String MAPTILE_SELECTED_TYPE = "splitter";

	static Boolean DRAGGING = false;
	static MapTile DRAGGING_MAPTILE;
	static Vector  DRAGGING_PREVPOS;

	static void init(
		Vector wsize, Vector msize, Vector mtsize
	) {
		WINDOW_SIZE  = wsize;
		MAP_SIZE     = msize;
		MAPTILE_SIZE = mtsize;
		println("Application Initialized Successfully.");
	}
}