static class App {
	static Vector APPLICATION_SIZE;

	static Vector WINDOW_SIZE;

	static Vector MAP_SIZE;

	static Vector    MAPTILE_SIZE;
	static String    MAPTILE_SELECTED_TYPE   = "block";
	static String[]  MAPTILE_AVALIABLE_TYPES = {"block", "reflector", "splitter", "beam", "sensor"};
	static Integer[] MAPTILE_RELATED_BUTTON  = {1      , 2          , 3         , 9     , 0       };

	static Integer TILETRAY_OFFSET;
	static Integer TILETRAY_BLOCK_DISTANCE;

	static Boolean DRAGGING = false;
	static MapTile DRAGGING_MAPTILE;
	static Vector  DRAGGING_PREVPOS;
	static Boolean DRAGGING_FROMTRAY = false;

  	static Integer BEAM_LENGTH_MAX = 256; 

	static void init(
		Vector asize, Vector wsize, Vector msize, Vector mtsize
	) {
		APPLICATION_SIZE   = asize;
		WINDOW_SIZE        = wsize;
		MAP_SIZE           = msize;
		MAPTILE_SIZE       = mtsize;

		TILETRAY_OFFSET         = floor(WINDOW_SIZE.x + (APPLICATION_SIZE.x-WINDOW_SIZE.x)/2);
		TILETRAY_BLOCK_DISTANCE = App.MAPTILE_SIZE.y*2;
		println("Application Initialized Successfully.");
	}
}
